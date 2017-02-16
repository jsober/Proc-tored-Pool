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

my $sent = process { 'foo' } $pool, 'id-foo';
ok $sent, 'process';
sync $pool;

is $assignment, [$pool, 'id-foo'], 'assignment';
is $success, [$pool, 'id-foo', 'foo'], 'success';
is $failure, undef, 'failure';

done_testing;
