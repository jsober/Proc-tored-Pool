use Test2::Bundle::Extended -target => 'Proc::tored::Pool::Manager';
use Path::Tiny;

my $name = 'proc-tored-pool-test';
my $dir = Path::Tiny->tempdir('temp.XXXXXX', CLEANUP => 1, EXLOCK => 0);
skip_all 'could not create writable temp directory' unless -w $dir;

my $assignment;
my $success;
my $failure;

my $mgr = $CLASS->new(
  name => $name,
  dir => "$dir",
  workers => 2,
  on_assignment => sub { $assignment = [@_] },
  on_success => sub { $success = [@_] },
  on_failure => sub { $failure = [@_] },
);

subtest 'positive path' => sub {
  undef $assignment;
  undef $success;
  undef $failure;
  ok $mgr->assign(sub { 'foo' }, 'id-foo'), 'assign';
  $mgr->sync;
  is $assignment, [$mgr, 'id-foo'], 'assigned';
  is $success, [$mgr, 'id-foo', 'foo'], 'success';
  is $failure, undef, 'failure';
};

subtest 'wantarray' => sub {
  undef $assignment;
  undef $success;
  undef $failure;
  ok $mgr->assign(sub { ('foo', 'bar') }, 'id-foo'), 'assign';
  $mgr->sync;
  is $assignment, [$mgr, 'id-foo'], 'assigned';
  is $success, [$mgr, 'id-foo', 'foo', 'bar'], 'success';
  is $failure, undef, 'failure';
};

subtest 'failure' => sub {
  undef $assignment;
  undef $success;
  undef $failure;
  ok $mgr->assign(sub { die 'bar' }, 'id-foo'), 'assign';
  $mgr->sync;
  is $assignment, [$mgr, 'id-foo'], 'assigned';
  is $success, undef, 'success';
  like $failure, [$mgr, 'id-foo', qr/bar/], 'failure';
};

subtest 'no id' => sub {
  undef $assignment;
  undef $success;
  undef $failure;
  ok $mgr->assign(sub { 'foo' }), 'assign';
  $mgr->sync;
  is $assignment, [$mgr, undef], 'assigned';
  is $success, [$mgr, undef, 'foo'], 'success';
  is $failure, undef, 'failure';
  ok $mgr->assign(sub { die 'bar' }), 'assigned to die';
  $mgr->sync;
  like $failure, [$mgr, undef, qr/bar/], 'failure';
};

subtest 'service' => sub {
  undef $assignment;
  undef $success;
  undef $failure;
  my $i = 0;

  $mgr->service(sub {
    if (++$i == 10) {
      $mgr->stop;
    } elsif ($i == 20) {
      die 'backstop';
    }

    $mgr->assign(sub { ($i, $i * 2) });
    return $i;
  });

  ok !$mgr->is_running, '!is_running';
  is $i, 10, 'expected work completed';
};

done_testing;
