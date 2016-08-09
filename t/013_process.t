use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Process;
use PrefApp::Puzzle::DockerCompose;

use Storable;

my $COMPOSE_PATH = `which docker-compose`;
chomp($COMPOSE_PATH);

my $TMP = "/tmp/c_" . int(rand(9999));

eval{

    mkdir($TMP);

    local %ENV = ();
    $ENV{HOME} = $TMP;
    $ENV{PUZZLE_SOURCE_PATH} = "./t/data";
    $ENV{PUZZLE_BOX} = "pieces_dev";

    my @command;

    PrefApp::Puzzle::DockerCompose->SET_EN_MOCKUP(sub {
        push @command, [@_[1..$#_]];

    });

    my $compilation_path = "$TMP/compilation";

    my $p = PrefApp::Puzzle::Process->new(

        opts=>{

            addenda=>"./t/data/addenda.yml",

            save=>"$TMP/compilation",

            "only-build"=>1,
        },


    );

    $p->up("arquitecto");
    
    ok(-d $compilation_path, "Compilation is created");

    ok(-f $compilation_path . "/puzzle.db", "Compilation database exists");

    ok(-d $compilation_path . '/arquitecto', "Service compilation for arquitecto exists");

    ok(-f $compilation_path . '/arquitecto/docker-compose.yml', "Docker compose of arquitecto exists");

    ok(-f $compilation_path . '/arquitecto/compose_base.yml', "Docker base of arquitecto exists");

    $p->ps;

    ok(
        &test_command(

            "$COMPOSE_PATH -f $compilation_path/arquitecto/docker-compose.yml ps",

            @{shift @command}

        ),

        "Ps was executed correctly"

    );


    $p->down;

    ok(
        &test_command(

            "$COMPOSE_PATH -f $compilation_path/arquitecto/docker-compose.yml stop arquitecto",

            @{shift @command}

        ),

        "Docker-compose command issued correctly"
    );

 
    ok(!-d $compilation_path . '/arquitecto', "Service compilation is destroyed");   

    done_testing;

    sub test_command{
        my ($model, @command_parts) = @_;

        return $model eq join(" ", @command_parts);
    }
};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);

1;
