package Proc::tored::Pool::Worker;
# ABSTRACT: executes a single code block

use strict;
use warnings;
use Moo;
use Try::Tiny;

with 'Proc::tored::Role::Running';

=head1 METHODS

=head2 work

A class method that executes a supplied C<CODE> ref. Returns an
C<ARRAY> ref of two values.

If the code executes successfully, an C<ARRAY> ref is returned containing a
true value followed by any values returned by the code ref. Note that the
supplied C<CODE> ref is evaluated in list context.

If the code dies when called, an C<ARRAY> ref is returned containing a false
value followed by the error thrown.

=cut

sub work {
  my ($class, $code, @args) = @_;
  my $self = $class->new(@args);
  $self->start;
  return unless $self->is_running;
  try { [1, $code->(@_)] }
  catch { [0, $_] };
}

1;
