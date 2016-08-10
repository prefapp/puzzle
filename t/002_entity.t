use strict;
use Test::More;

use PrefApp::Puzzle::DB;
use PrefApp::Puzzle::Vault;
use PrefApp::Puzzle::Entity;

my $db = PrefApp::Puzzle::DB->new;
my $vault = PrefApp::Puzzle::Vault->new(

    refDB=>$db
);

my @entities = map { MockEntity->new(

    refVault=>$vault

)->create } 1..10000;


ok($vault->get('mock_entity_0'), "An entity is retrievable by its alias");

ok($vault->get('mock_entity_500'), "An entity is retrievable by its alias");

done_testing;

package MockEntity;


use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

my $ALIAS_COUNT = 1;

sub BUILD_ALIAS{

    "mock_entity_" . $ALIAS_COUNT++;
}



1;
