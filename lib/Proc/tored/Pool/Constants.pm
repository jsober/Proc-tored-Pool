package Proc::tored::Pool::Constants;
# ABSTRACT: Constants used by Proc::tored::Pool

use strict;
use warnings;
use parent 'Exporter';

use constant assignment => 'assignment';
use constant success => 'success';
use constant failure => 'failure';

BEGIN {
  our %EXPORT_TAGS = (events => [qw(assignment success failure)]);
  our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;
};

=head1 EVENT CONSTANTS

=head2 assignment

Triggered immediately after a task has been assigned to a worker process.

=head2 success

Triggered once the manager collects the result of the successful execution of a
task.

=head2 failure

Triggered once the manager collects the result of a task which died or that had
a non-zero exit status.

=cut

1;
