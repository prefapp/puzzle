use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Boot;
use PrefApp::Puzzle::Vault;

use Storable;

my $TMP = "/tmp/c_" . int(rand(9999));

eval{

    mkdir($TMP);

    local %ENV = ();
    $ENV{HOME} = $TMP;
    $ENV{PUZZLE_SOURCE_PATH} = "./t/data";
    $ENV{PUZZLE_BOX} = "pieces_dev";

    my $b = PrefApp::Puzzle::Boot->new(

        opts=>{

            addenda=>"./t/data/addenda.yml",

            save=>"$TMP/compilation",

            from=>{
                "arquitecto" => "/tmp/foo"
            }
        },


    )->boot;

    ok($b->refDB, "Data base correctly initialized");

    my $piece = $b->vault->get('arquitecto_piece');

    ok($piece, "Piece loaded");

    ok($piece && $piece->compose, "Compose correctly loaded");

    ok($b->vault->get('env'), "We have an environment");

    ok($b->vault->get('addenda'), "We have an addenda");

    my @services = $b->pieceCommands->validServices;

    ok(@services == 1 && $services[0] eq 'arquitecto', 
        "Services are correctly established"
    );

    $b->refCompilation->create();
    $b->refCompilation->createDB($b->refDB);

    ok(-f $TMP . '/compilation/puzzle.db', "Database exported");

    local %ENV; 

    $ENV{A} = 1;
    $ENV{B} = 2;
    $ENV{C} = 3;
    $ENV{D} = 4;
    $ENV{HOME} = $TMP;

    my $n_db = retrieve $TMP . "/compilation/puzzle.db";

    ok($n_db, "Database retrieved");

    #print Dumper($n_db->{entities}->{services_compilation_args}->services);

    my $bb = PrefApp::Puzzle::Boot->new(

        opts=>{
            save=>$TMP . '/compilation',
        }

    )->boot;

    my $vault =  $bb->vault;

    ok($vault->get('arquitecto_piece'), "Piece retrieved correctly");

    ok($vault->get('arquitecto_piece_compose'), "Compose retrieved correctly");

    ok($vault->get('addenda'), "Addenda was stored");

    my $env = $vault->get('env');

    ok($env && $env->get('HOME') && $env->get("A") eq 1, "Compilation environment is correct");

    @services = $bb->pieceCommands->validServices;

    ok(@services == 1 && $services[0] eq 'arquitecto', 
        "Services are correctly established"
    );

    ok($vault->get('arquitecto_piece')->compose, "Piece's main compose is kept");

    my $sca = $bb->vault->get('services_compilation_args');

    ok($sca, "Services compilation args are booted");

    ok($sca->getServiceArgs('arquitecto')->{from},
        "Args for compilation are correct"
    );

   # $Data::Dumper::Indent = 1;

   # print Dumper(

   #     retrieve $TMP . "/compilation/puzzle.db"

   # ); 
   #
    done_testing;

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);

1;
