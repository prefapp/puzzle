package PrefApp::Puzzle::Entity;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use Storable qw(freeze thaw);

has(

    service=>undef,
    
    alias=>undef,
    
    refVault=>undef,   

);

sub FREEZE_KEYS {qw(
    service
    alias
)}

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

sub STORABLE_freeze{
    my ($self, $cloning, @keys) = @_;
    
    return if($cloning);    
    
    return freeze({
        map {
            $_ => $self->{$_}
        } $self->FREEZE_KEYS
    })

}

sub STORABLE_thaw{
    my ($self, $cloning, $serialized, @keys) = @_;

    $serialized = thaw($serialized);

    foreach($self->FREEZE_KEYS){

        $self->{$_} = $serialized->{$_};
    }

    $self;
}


1;
