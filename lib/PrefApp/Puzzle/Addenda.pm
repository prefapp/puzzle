package PrefApp::Puzzle::Addenda;


use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    name=>undef,

    data=>undef,

);

sub BUILD_ALIAS{
    "addenda"
}

sub exports{
    $_[0]->data->{exports};
}

1;
