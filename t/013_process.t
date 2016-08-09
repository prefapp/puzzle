use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Process;

use Storable;

my $TMP = "/tmp/c_" . int(rand(9999));

eval{

    mkdir($TMP);

    local %ENV = ();
    $ENV{HOME} = $TMP;
    $ENV{PUZZLE_SOURCE_PATH} = "./t/data";
    $ENV{PUZZLE_BOX} = "pieces_dev";

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

    $p->down;

    done_testing;

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);

1;
