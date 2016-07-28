use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Commands;

my $TMP = "/tmp/c_" . int(rand(9999));

eval{
    
    $ENV{PUZZLE_SOURCE_PATH} = "./t/data";

    $ENV{PUZZLE_BOX} = "pieces_t2";

    my $c = PrefApp::Puzzle::Commands->new;

    ok(keys(%{$c->validServices}) ==3, "Three valid services");

    my @services_list = $c->c__listValidServices;

    ok($services_list[0] eq 'c' && $services_list[2] eq 'a', "Services are ordered");

    my $db = $c->db;

    ok($db->getSection("b",'foo')->{'a'} == 1, "Related value is correct");

    done_testing;

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);
