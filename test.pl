use strict;
use warnings;
use Proc::tored::Pool;

my $pool = pool 'name',
  hire 10,
  in '/tmp',
  on success, call {
    my ($me, $id, @results) = @_;
    printf "%02d ** 2 = %d\n", @results;
  },
;

my $i = 0;
my $max = 50;

run {
  return if ++$i == $max;
  process { sleep $i % 3; ($i, $i ** 2) } $pool;
  return 1;
} $pool;

exit 0;
