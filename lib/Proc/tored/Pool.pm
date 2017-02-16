package Proc::tored::Pool;
# ABSTRACT: managed work pool with Proc::tored and Parallel::ForkManager

=head1 SYNOPSIS

  use Proc::tored::Pool;

  # Create a worker pool service
  my $pool = pool 'thing-doer', in '/var/run', capacity 10,
    on success, call {
      my ($me, $id, @results) = @_;
      print "thing $id complete: @results";
    },
    on failure, call {
      my ($me, $id, $message) = @_;
      warn "thing $id failed: $message";
    };

  # Do things with the pool
  run {
    my ($thing_id, $thing) = get_next_thing();
    process { do_things($thing) } $pool, $thing_id;
  } $pool;

=head1 DESCRIPTION

Provides a simple and fast interfact to build and manage a pool of forked
worker processes. The process is controlled using a pidfile and POSIX signals.

=cut

use strict;
use warnings;
require Exporter;
use Proc::tored::Pool::Constants ':events';
use Proc::tored::Pool::Loop;
use Proc::tored;

use parent 'Exporter';

our @EXPORT = (
  @Proc::tored::EXPORT,
  qw(
    assignment
    success
    failure
    pool
    capacity
    on
    call
    pending
    process
  )
);

=head1 EXPORTED SUBROUTINES

=head2 pool

=head2 capacity

=head2 on

=head2 call

=head2 pending

=head2 process

=head1 SEE ALSO

L<Proc::tored>, L<Parallel::ForkManager>

=cut

sub pool     ($%)   { Proc::tored::Pool::Loop->new(name => shift, @_); }
sub capacity ($@)   { workers => shift, @_ }
sub on       ($@)   { 'on_' . shift, @_ }
sub call     (&@)   { @_ }
sub pending  ($)    { $_[0]->pending }
sub process  (&$;$) { $_[1]->assign($_[0], $_[2]) };

1;
