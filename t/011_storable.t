use strict;
use Test::More;

use Storable;
use File::Path qw(remove_tree);

my $TMP = "/tmp/c_" . int(rand(9999));

use PrefApp::Puzzle::Piece;
use PrefApp::Puzzle::Compose;
use PrefApp::Puzzle::PieceEvent;

eval{

    mkdir($TMP);

    my $e = PrefApp::Puzzle::Piece->new(

        service=>"foo",

        compose=>PrefApp::Puzzle::Compose->new(referer=>"foo"),

        events=>{

            map {

                $_ => PrefApp::Puzzle::PieceEvent->new(

                    name=>$_,

                    referer=>"foo_piece",

                    tasks=>["task_for_" . $_ ]

                )

            } qw(on_create on_destroy)
        }
    
    );

    store $e, $TMP . '/test';

    my $n = retrieve $TMP ."/test";

 #   print Dumper($n);
    ok($n->service eq 'foo' &&
        $n->alias eq 'foo_piece', 
        "Service was correctly frozen");

    ok($n->events->{on_create} &&
        $n->events->{on_create}->name eq 'on_create', 

        "Event serialized correctly");

    done_testing;

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);

1;
