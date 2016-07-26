use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Commands;

my $TMP = "/tmp/c_" . int(rand(9999));

eval{

    $ENV{PUZZLE_COMPILATION_PATH} = $TMP . '/compilation';    
    $ENV{PUZZLE_SOURCE_PATH} = "./t/data";

    $ENV{PUZZLE_BOX} = "pieces_dev";

    my $c = PrefApp::Puzzle::Commands->new;

    $c->up("arquitecto", '--only-build');

    ok(-d $ENV{PUZZLE_COMPILATION_PATH}, "Compilation directory created");

    ok(-d $ENV{PUZZLE_COMPILATION_PATH} . '/arquitecto', "Service compilation created");

    ok(-f $ENV{PUZZLE_COMPILATION_PATH} . '/arquitecto/docker-compose.yml', "Main compilation file created");

    ok(-f $ENV{PUZZLE_COMPILATION_PATH} . '/arquitecto/arquitecto_base_puzzle.yml', "Extended file created");

    done_testing();

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);

