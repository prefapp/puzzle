use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Environment;

my $TMP = "/tmp/c_" . int(rand(9999));

eval{

    mkdir($TMP);

    $ENV{HOME} = $TMP;
    $ENV{PUZZLE_COMPILATION_PATH} = undef;
    $ENV{PUZZLE_SOURCE_PATH} = undef;

    PrefApp::Puzzle::Environment->new(

        puzzle_compilation_path=>$TMP . '/compilation'

    )->store;

    ok(-f $TMP . '/.puzzle', "Env file created");

    my $env = PrefApp::Puzzle::Environment->new;

    ok($env->puzzle_compilation_path =~ /compilation/, "Value stored in configuration");

    $ENV{PUZZLE_COMPILATION_PATH} = "foo";

    $env = PrefApp::Puzzle::Environment->new;

    ok($env->puzzle_compilation_path eq "foo", "Environment value takes predecence over stored configuration");

    $env = PrefApp::Puzzle::Environment->new(

        puzzle_compilation_path=>"/home/foo"

    );

    ok($env->puzzle_compilation_path eq "/home/foo", "Opts values take predecence over everything else");
    
    done_testing;

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);
