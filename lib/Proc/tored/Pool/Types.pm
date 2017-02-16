package Proc::tored::Pool::Types;
# ABSTRACT: Type constraints used by Proc::tored::Pool

use strict;
use warnings;
use Proc::tored::Pool::Constants ':events';
use Types::Standard -types;
use Type::Utils -all;
use Type::Library -base,
  -declare => qw(
    NonEmptyStr
    Dir
    Task
    PosInt
    Event
  );

=head1 TYPES

=head2 NonEmptyStr

A C<Str> that contains at least one non-whitespace character.

=head2 Dir

A L</NonEmptyStr> that is a valid directory path.

=head2 PosInt

An C<Int> with a positive value.

=head2 Event

One of L<Proc::tored::Pool::Constants/assignment>,
L<Proc::tored::Pool::Constants/success>, or
L<Proc::tored::Pool::Constants/failure>.

=cut

declare NonEmptyStr, as Str, where { $_ =~ /\S/ };
declare Dir, as NonEmptyStr, where { -d $_ };
declare PosInt, as Int, where { $_ > 0 };
declare Event, as Enum[assignment, success, failure];

1;
