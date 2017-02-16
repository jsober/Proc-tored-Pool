package Proc::tored::Pool;
# ABSTRACT: Managed worker pool with Proc::tored and Parallel::ForkManager

=head1 NAME

Proc::tored::Pool

=head1 SYNOPSIS

=head1 DESCRIPTION

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
    hire
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

=cut

sub pool     ($%)   { Proc::tored::Pool::Loop->new(name => shift, @_); }
sub capacity ($@)   { workers => shift, @_ }
sub on       ($@)   { 'on_' . shift, @_ }
sub call     (&@)   { @_ }
sub pending  ($)    { $_[0]->pending }
sub process  (&$;$) { $_[1]->assign($_[0], $_[2]) };

1;
