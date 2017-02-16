use Test2::Bundle::Extended -target => 'Proc::tored::Pool::Worker';

ok my $worker = $CLASS->new, 'new';
is $worker->work(sub { 'foo' }), [1, 'foo'], 'success -wantarray';
is $worker->work(sub { ('foo', 'bar') }), [1, 'foo', 'bar'], 'success +wantarray';
like $worker->work(sub { die 'error!' }), [0, qr/error!/], 'failure';

done_testing;
