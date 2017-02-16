package Proc::tored::Pool::Loop;

use strict;
use warnings;

use Moo;
use Carp;
use Types::Standard -types;
use Type::Utils qw(declare as where);
use Try::Tiny;
use Time::HiRes 'sleep';
use Parallel::ForkManager;
use Proc::tored::Pool::Constants ':events';
use Proc::tored::Pool::Types -types;
use Proc::tored::Pool::Worker;

extends 'Proc::tored::Manager';

has workers => (
  is  => 'ro',
  isa => PosInt,
  required => 1,
);

has on_assignment => (
  is  => 'ro',
  isa => Maybe[CodeRef],
);

has on_success => (
  is  => 'ro',
  isa => Maybe[CodeRef],
);

has on_failure => (
  is  => 'ro',
  isa => Maybe[CodeRef],
);

has pending => (
  is  => 'ro',
  isa => Int,
  default => 0,
  init_arg => undef,
);

sub trigger {
  my ($self, $event, $ident, @args) = @_;
  Event->assert_valid($event);
  my $acc = $self->can("on_$event") or die "unknown event type: $event";
  if (my $cb = $self->$acc()) {
    try { $cb->($self, $ident, @args) }
    catch { warn "error triggering callback for task $ident: $_" };
  }
}

has forkmgr => (
  is  => 'lazy',
  isa => InstanceOf['Parallel::ForkManager'],
  init_arg => undef,
);

sub _build_forkmgr {
  my $self = shift;
  my $pm = Parallel::ForkManager->new($self->workers);

  $pm->run_on_start(sub {
    my ($pid, $ident) = @_;
    ++$self->{pending};
    $self->trigger(assignment, $ident);
  });

  $pm->run_on_finish(sub {
    my ($pid, $code, $ident, $signal, $core, $data) = @_;
    --$self->{pending};

    if ($code == 0) {
      my ($success, @results) = @$data;

      if ($success) {
        $self->trigger(success, $ident, @results);
      }
      else {
        $self->trigger(failure, $ident, @results);
      }
    }
    else {
      $self->trigger(failure, $ident, "task died with exit code $code (signal $signal)");
    }
  });

  return $pm;
}

after service => sub {
  my $self = shift;
  $self->forkmgr->wait_all_children;
};

sub assign {
  my $self = shift;
  my $code = shift;
  push @_, sub { Proc::tored::Pool::Worker->work($code) };
  $self->forkmgr->wait_for_available_procs(1);
  $self->forkmgr->start_child(@_);
  $self->forkmgr->wait_children; # triggers pending callbacks w/o blocking
  return 1;
}

1;
