use Test2::Bundle::Extended '!call';
use Path::Tiny;
use Proc::tored::Pool;

my $name = 'proc-tored-pool-test';
my $dir = Path::Tiny->tempdir('temp.XXXXXX', CLEANUP => 1, EXLOCK => 0);
skip_all 'could not create writable temp directory' unless -w $dir;

my $assignment;
my $success;
my $failure;

my $pool = pool $name, in $dir, capacity 1,
  on assignment, call { $assignment = [@_] },
  on success, call { $success = [@_] },
  on failure, call { $failure = [@_] };

ok $pool, 'build';

subtest 'positive path' => sub {
  undef $assignment;
  undef $success;
  undef $failure;

  my $sent = process { 'foo' } $pool, 'id-foo';
  ok $sent, 'process';
  sync $pool;

  is $assignment, [$pool, 'id-foo'], 'assignment';
  is $success, [$pool, 'id-foo', 'foo'], 'success';
  is $failure, undef, 'failure';
};

subtest 'failure' => sub {
  undef $assignment;
  undef $success;
  undef $failure;

  process { die 'bar' } $pool, 'id-bar';
  sync $pool;

  is $assignment, [$pool, 'id-bar'], 'assignment';
  is $success, undef, 'success';
  like $failure, [$pool, 'id-bar', qr/bar/], 'failure';
};

subtest 'run' => sub {
  my $assignment = 0;
  my $success = 0;
  my $failure = 0;
  my $zapped;
  my $i = 0;

  my $pool = pool $name, in $dir, capacity 4,
    on assignment, call { ++$assignment },
    on success, call { ++$success },
    on failure, call { ++$failure };

  run {
    if (++$i == 10) {
      zap $pool, 5, 1;
    }
    elsif ($i == 20) {
      stop $pool; # backstop
    }

    process { $i * 2 } $pool;
    return $i;
  } $pool;

  ok !$zapped, 'zapped';
  ok !(running $pool), '!is_running';
  is $i, 10, 'expected work completed';
  is $assignment, 10, 'assignment';
  is $success, 10, 'success';
  is $failure, 0, 'failure';
};

done_testing;
