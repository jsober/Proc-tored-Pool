package Proc::tored::Pool::Worker;

use strict;
use warnings;
use Moo;

with 'Proc::tored::Role::Running';

sub work {
  my ($class, $code) = @_;

  my $self = $class->new;
  $self->start;

  if ($self->is_running) {
    return $code->(@_);
  }

  return;
}

1;
