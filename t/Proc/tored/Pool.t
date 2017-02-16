use Test2::Bundle::Extended;
use Path::Tiny;

my $name = 'proc-tored-pool-test';
my $dir = Path::Tiny->tempdir('temp.XXXXXX', CLEANUP => 1, EXLOCK => 0);
skip_all 'could not create writable temp directory' unless -w $dir;

ok 1;

done_testing;
