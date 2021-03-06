use strict;
use Test::More;

use Data::Dumper;

use PrefApp::Puzzle::Vault;
use PrefApp::Puzzle::Piece;
use PrefApp::Puzzle::LoaderPiece;
use PrefApp::Puzzle::AttributeFinder;
use PrefApp::Puzzle::DB;


my $vault = PrefApp::Puzzle::Vault->new(

    refDB=>PrefApp::Puzzle::DB->new
);

my $piece = PrefApp::Puzzle::LoaderPiece->new(

    basePath=>"t/data/",

    refVault=>$vault

)->load('piece', box=>"pieces_t");

ok($piece && $piece->alias eq 'piece_piece', "Piece loaded");

ok($piece->compose && $piece->compose->alias eq 'piece_piece_compose', "Compose related to piece loaded");

my $compose = $piece->compose;

ok(!(grep { !$compose->constructions->{$_}} qw(data arquitecto arquitecto_minions)), "Constructions built");

ok(
    $compose->constructions->{"arquitecto"}->compose_base &&

    $compose->constructions->{"arquitecto"}->compose_base->alias eq

        "piece_piece_compose_arquitecto_compose",

    "Compose base correctly related"

);

ok(PrefApp::Puzzle::AttributeFinder->new->find(

    "arquitecto.command",

    $piece

)=~ /root/, "Recursive searches of attributes work");

my $install_tasks = $piece->getTasksFor('install');
ok($install_tasks, "Install tasks are retrievable");

ok($install_tasks->tasksForContainer('foo'), "Foo has install tasks");

ok($install_tasks->tasksForContainer('foo2'), "Foo2 has install tasks");

my @events_on_create = $piece->eventFired('on_create');

ok($events_on_create[0] &&
    $events_on_create[0]->label eq 'install', 

    "Tasks for event on_create prepared"
);



done_testing();




1;
