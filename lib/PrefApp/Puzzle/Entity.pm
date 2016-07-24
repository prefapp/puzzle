package PrefApp::Puzzle::Entity;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    service=>undef,
    
    alias=>undef,
    
    refVault=>undef,   

);

sub BUILD_ALIAS :Abstract {}

sub initialize{

    $_[0]->SUPER::initialize(@_[1..$#_]);

    $_[0]->alias($_[0]->BUILD_ALIAS);

    $_[0];
}

sub create{
    my ($self) = @_;

    $self->refVault->addEntity(

        $self->alias,     
    
        $self
    );

    $self;
}

1;
