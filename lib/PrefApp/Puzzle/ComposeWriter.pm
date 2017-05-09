package PrefApp::Puzzle::ComposeWriter;

use strict;
use Eixo::Base::Clase "PrefApp::Puzzle::Base";

use PrefApp::Puzzle::YAML;

has(

    docker_compose=>"",

    compose_data=>{},

    refDB=>undef,

    refCompilation=>undef,

    args=>{},

    pieceRef=>undef,
);

sub write{
    my ($self, $compose, $piece) = @_;

    $self->__write($compose, $piece);

    return PrefApp::Puzzle::YAML::Dump(

        $self->compose_data

    );
}

    sub __write{
        my ($self, $compose, $piece) = @_;

        $self->__compileConstructions($compose, $piece);

    }


    sub __compileConstructions{
        my ($self, $compose, $piece) = @_;

        foreach(keys(%{$compose->constructions})){

            $self->__compileConstruction(

                $_, 

                $compose->constructions->{$_},

                $piece
            );
        }
    }

    sub __mountVolume{
        my ($self, $construction, $volume) = @_;
        
        $construction->data->{volumes} ||= [];

        push @{$construction->data->{volumes}}, $volume;
    }

    sub __umountVolume{
        my ($self, $construction, $volume) = @_;

        $construction->data->{volumes} = [grep {

            $_ ne $volume

        } @{$construction->data->{volumes}}];
    }

    sub __find{

        PrefApp::Puzzle::AttributeFinder->new->find(

            $_[1], $_[2]

        )
    }

    sub __exportArgs{
        JSON::XS->new->encode($_[0]->args)
    }

    sub __exportEnv{
        my ($self, $env) = @_;
        JSON::XS->new->encode($env || \%ENV)
    }


1;
