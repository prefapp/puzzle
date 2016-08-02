use strict;
use Test::More;

my $c = `which docker-compose`;

ok($c, "Docker compose is installed on the machine");


done_testing();
