package PrefApp::Puzzle::Compose;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    path=>undef,

    referer=>undef,

    data=>{},

    constructions=>{}
);

sub FREEZE_KEYS{

    $_[0]->SUPER::FREEZE_KEYS,

    qw(

        path
        referer
        data
        constructions
    )
}

sub BUILD_ALIAS{
    $_[0]->referer . '_compose' 
}

sub extends :Sig(self, s){
    my ($self, $construction) = @_;

    my $e = $self->data->{$construction}->{extends};
    
    $e && $e->{file};
}

sub getExtendedComposes{
    my ($self) = @_;

    return map {
        
        $_->compose_base, 

        $_->compose_base->getExtendedComposes()
    }
    grep {

        $_->compose_base

    } values(%{$self->constructions})

}

1;
