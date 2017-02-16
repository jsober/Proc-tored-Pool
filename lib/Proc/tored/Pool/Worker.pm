package Proc::tored::Pool::Worker;
# ABSTRACT: executes a single code block

use strict;
use warnings;
use Moo;
use Try::Tiny;

with 'Proc::tored::Role::Running';

sub work {
  my ($class, $code) = @_;
  my $self = $class->new;
  $self->start;
  return unless $self->is_running;
  try { [1, $code->(@_)] }
  catch { [0, $_] };
}

1;
