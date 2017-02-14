package Proc::tored::Pool::Types;

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

declare NonEmptyStr, as Str, where { $_ =~ /\S/ };
declare Dir, as NonEmptyStr, where { -d $_ };
declare Task, as Tuple[NonEmptyStr, CodeRef];
declare PosInt, as Int, where { $_ > 0 };
declare Event, as Enum[assignment, success, failure];

1;
