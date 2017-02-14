package Proc::tored::Pool;

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
    hire
    on
    call
    pending
    process
  )
);

sub pool    ($%)   { Proc::tored::Pool::Loop->new(name => shift, @_); }
sub hire    ($@)   { workers => shift, @_ }
sub on      ($@)   { 'on_' . shift, @_ }
sub call    (&@)   { @_ }
sub pending ($)    { $_[0]->pending }
sub process (&$;$) { $_[1]->assign($_[0], $_[2]) };

1;
