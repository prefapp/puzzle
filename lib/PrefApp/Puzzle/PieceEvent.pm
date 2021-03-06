package PrefApp::Puzzle::PieceEvent;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

sub FREEZE_KEYS{

    $_[0]->SUPER::FREEZE_KEYS,

    qw(
        name
        referer
        tasks
    )
}

has(

    name=>undef,

    referer=>undef,

    tasks=>[],
    
);

sub BUILD_ALIAS{
    join("_", $_[0]->referer, $_[0]->name, "events")
}

1;
