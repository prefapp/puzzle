package PrefApp::Puzzle::Vault;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    __entities=> {}

);

sub get{
    $_[0]->__entities->{$_[1]};
}

sub addEntity :Sig(self, s, PrefApp::Puzzle::Entity){
    my ($self, $name, $entity) = @_;
    
    $self->__entities->{$name} = $entity;
}
