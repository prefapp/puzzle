package PrefApp::Puzzle::ComposeConstruction;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    path=>undef,

    name=>undef,

    data=>undef,

    compose=>undef,
 
    referer=>undef,   
    
    compose_base=>undef,

    compose_base_as=>undef,

    from_mounted=>undef,
);

sub FREEZE_KEYS{

    $_[0]->SUPER::FREEZE_KEYS,

    qw(
        path
        name
        data
        compose
        referer
        compose_base
        compose_base_as
        from_mounted
    )
}

sub BUILD_ALIAS{
    $_[0]->referer . '_' . $_[0]->name 
}


1;
