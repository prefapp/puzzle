
use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Process;
use PrefApp::Puzzle::DockerCompose;

my $TMP = "/tmp/c_" . int(rand(9999));

eval{

    my @comandos;

    PrefApp::Puzzle::DockerCompose->SET_EN_MOCKUP(sub {

        push @comandos, \@_;

    });


    mkdir($TMP);

    local %ENV = ();

    $ENV{PUZZLE_COMPILATION_PATH} = $TMP . '/compilation';    
    $ENV{PUZZLE_SOURCE_PATH} = "./t/data";

    $ENV{PUZZLE_BOX} = "pieces_dev";
    $ENV{HOME} = $TMP;

    $ENV{A} = "a";
    $ENV{B} = "b";
    $ENV{C} = "c";

    my $c = PrefApp::Puzzle::Process->new(

        opts=>{
            "only-build" => 1,
        }

    );

    $c->up("arquitecto");
 
    my $l = $c->dockerCommands

                ->__dockerForService('arquitecto');

    ok($l->env->{A} eq 'a' && $l->env->{B} eq 'b', "Environment is correctly stored");

    $l->up;
 #   print Dumper($comandos[0]);

    @comandos = ();

    local %ENV = ();

    $ENV{A} = "z";
    $ENV{PUZZLE_COMPILATION_PATH} = $TMP . '/compilation';    
    $ENV{PUZZLE_SOURCE_PATH} = "./t/data";

    $ENV{PUZZLE_BOX} = "pieces_dev";
    $ENV{HOME} = $TMP;
    
    $c = PrefApp::Puzzle::Process->new(

        opts=>{
            "only-build" => 1,
        }
    );

    $c->up("arquitecto");
 
    $l = $c->dockerCommands

                ->__dockerForService('arquitecto');

    ok($l->env->{A} eq 'z' && $l->env->{B} eq 'b', "Environment is correctly rewritten");

    $l->up;
    #print Dumper($comandos[0]);

    done_testing;

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);
