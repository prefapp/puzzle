package PrefApp::Puzzle::ComposeConstruction;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    name=>undef,

    data=>undef,

    compose=>undef,
 
    referer=>undef,   
    
    compose_base=>undef,

    compose_base_as=>undef,
);

sub BUILD_ALIAS{
    $_[0]->referer . '_' . $_[0]->name 
}


1;
