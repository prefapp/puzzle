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

    # let's list the images
    $c->c__loadServicesImages(qw(arquitecto));
    my @images = $c->c__listServiceImages("arquitecto");

    ok((grep {$_ eq 'busybox'} @images), "Images are correct");

    done_testing();

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);

