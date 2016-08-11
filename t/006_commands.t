use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Process;

my $TMP = "/tmp/c_" . int(rand(9999));

eval{

    $ENV{HOME} = "$TMP"; 
   
    $ENV{PUZZLE_SOURCE_PATH} = "./t/data";

    $ENV{PUZZLE_BOX} = "pieces_t2";

    $ENV{PUZZLE_COMPILATION_PATH} = "$TMP";

    my $p = PrefApp::Puzzle::Process->new(

        opts=>{}

    );

    my @services_list = $p->__servicesList;

    ok(@services_list == 3, "Three valid services");


   # my @services_list = $p->c__listValidServices;

   ok($services_list[0] eq 'a' && $services_list[1] eq 'b' && $services_list[2] eq 'c', "Services are ordered");

   # $c->c__dbPiece($c->c__getPieceForService("a"));
   # $c->c__dbPiece($c->c__getPieceForService("b"));
   # $c->c__dbPiece($c->c__getPieceForService("c"));

   # my $db = $c->db;

   # ok($db->getSection("b",'foo')->{'a'} == 1, "Related value is correct");

    done_testing;

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);
