use strict;
use Test::More;

use Data::Dumper;

use PrefApp::Puzzle::Vault;
use PrefApp::Puzzle::Piece;
use PrefApp::Puzzle::LoaderPiece;
use PrefApp::Puzzle::AttributeFinder;


my $vault = PrefApp::Puzzle::Vault->new;

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

done_testing();




1;
