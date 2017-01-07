package PrefApp::Puzzle::LoaderComposeV1;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::LoaderCompose';

use File::Basename qw(fileparse);

    sub __loadConstructions{
        my ($self, $compose, $path) = @_;

        my ($f, $relativePath) = fileparse($path);

        my %constructions = map {

            $_ => $self->loader(

                $self->LOADER_COMPOSE_CONSTRUCTION_CLASS,


            )->load(

                $_,

                $compose->service,

                referer=>$compose->alias,

                data=>$compose->data->{$_},

                path=>$relativePath
            )
            

        } keys(%{$compose->data});

        \%constructions
    }

1;
