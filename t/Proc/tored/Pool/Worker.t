use Test2::Bundle::Extended -target => 'Proc::tored::Pool::Worker';
use Path::Tiny;

my $dir = Path::Tiny->tempdir('temp.XXXXXX', CLEANUP => 1, EXLOCK => 0);
skip_all 'could not create writable temp directory' unless -w $dir;
my $term_file = $dir->child("term_file_$$.term");
my @args = (term_file => "$term_file");

is $CLASS->work(sub { 'foo' }, @args), [1, 'foo'], 'success -wantarray';
is $CLASS->work(sub { ('foo', 'bar') }, @args), [1, 'foo', 'bar'], 'success +wantarray';
like $CLASS->work(sub { die 'error!' }, @args), [0, qr/error!/], 'failure';

done_testing;
