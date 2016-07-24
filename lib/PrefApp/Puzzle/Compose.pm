package PrefApp::Puzzle::Compose;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    referer=>undef,

    data=>{},

    constructions=>{}

);

sub BUILD_ALIAS{
    $_[0]->referer . '_compose' 
}

sub extends :Sig(self, s){
    my ($self, $construction) = @_;

    my $e = $self->data->{$construction}->{extends};
    
    $e && $e->{file};
}


1;
