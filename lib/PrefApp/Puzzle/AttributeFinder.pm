package PrefApp::Puzzle::AttributeFinder;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use Scalar::Util qw(blessed);

sub find :Sig(self, s, PrefApp::Puzzle::Entity){
    my ($self, $attribute, $entity) = @_;

    return $self->__findPiece($attribute, $entity) 
        if(blessed($entity) eq "PrefApp::Puzzle::Piece");

    return $self->__findCompose($attribute, $entity) 
        if(blessed($entity) eq "PrefApp::Puzzle::Compose");

    return $self->__findConstruction($attribute, $entity) 
        if(blessed($entity) eq "PrefApp::Puzzle::ComposeConstruction");
}

    sub __findPiece{
        my ($self, $attribute, $piece) = @_;

        return $self->find($attribute, $piece->compose)
    }

    sub __findCompose{
        my ($self, $attribute, $compose) = @_;

        my ($construction, $key) = split(/\./, $attribute);

        my $c = $compose->constructions->{$construction} ||

            $self->fatal($compose->alias, " does not posses a construction named ". $construction);

        return $self->find($attribute, $c);
    }

    sub __findConstruction{
        my ($self, $attribute, $construction) = @_;

        my ($konstruction, $key) = split(/\./, $attribute);
        
        my $v = $construction->data->{$key};

        return $v if($v);
        
        if($construction->compose_base){    
        
            # we have to search in the base service from the extended compose

            my $extended_attribute = $construction->compose_base_as . '.' . $key;

            $self->find($extended_attribute, $construction->compose_base) 
        }
    }

    

1;
