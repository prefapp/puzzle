use strict;
use Test::More;

use File::Path qw(remove_tree);

use PrefApp::Puzzle::Compilation;

my $TMP = "/tmp/c_" . int(rand(9999));

eval{

    my $c = PrefApp::Puzzle::Compilation->new(

        path=>$TMP,

        validServices=>[qw(
            a b c
        )]

    );

    $c->create;

    ok(-d $TMP, "Compilation created");

    $c->createService("a", 

        "docker_compose.yml" => "blabla"
    );

    ok(-d $TMP . '/a', "Service compilation created");

    ok(-f $TMP . '/a/docker_compose.yml', "Service file created");

    my @services = $c->getServices;

    ok((grep {$_ eq 'a'} @services), "Service installed");

    done_testing;

};
if($@){
    use Data::Dumper;
    ok(undef, Dumper($@));
}

remove_tree($TMP) if(-d $TMP);
