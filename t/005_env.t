use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Environment;

my $TMP = "/tmp/c_" . int(rand(9999));

eval{

    mkdir($TMP);

    $ENV{HOME} = $TMP;

    PrefApp::Puzzle::Environment->new(

        puzzle_compilation_path=>$TMP . '/compilation'

    )->store;

    ok(-f $TMP . '/.puzzle', "Env file created");

    my $env = PrefApp::Puzzle::Environment->new;

    ok($env->puzzle_compilation_path =~ /compilation/, "Value stored in configuration");

    $ENV{PUZZLE_COMPILATION_PATH} = "foo";

    $env = PrefApp::Puzzle::Environment->new;

    ok($env->puzzle_compilation_path eq "foo", "Environment value always takes precedence");

    done_testing;

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);
