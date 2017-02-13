requires 'Moo'                   => 0;
requires 'Parallel::ForkManager' => 0;
requires 'Proc::tored'           => 0;
requires 'Type::Tiny'            => 0;

on test => sub {
  requires 'Test2::Bundle::Extended' => 0;
};
