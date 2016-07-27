package PrefApp::Puzzle::Piece;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    data=>{},

    compose=>undef,
);

sub BUILD_ALIAS{
    $_[0]->service . '_piece' 
}

sub getApplicationContainers{
    $_[0]->data->{application_containers} || [];
}

sub origin{
    $_[0]->data->{origin};
}

sub exports{
    $_[0]->data->{exports} || {};
}

sub related{
    $_[0]->data->{related} || {};
}

1;
