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

1;
