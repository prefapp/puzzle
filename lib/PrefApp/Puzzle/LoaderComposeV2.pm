package PrefApp::Puzzle::LoaderComposeV2;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::LoaderCompose';

use File::Basename qw(fileparse);

use PrefApp::Puzzle::ComposeV2;

sub COMPOSE_CLASS{
    "PrefApp::Puzzle::ComposeV2";
}

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

                data=>$compose->data->{services}->{$_},

                path=>$relativePath
            )
            

        } keys(%{$compose->data->{services}});

        \%constructions
    }

    sub __loadAdditionalArtifacts{
        my ($self, $compose, $data) = @_;

        $compose->artifacts({

            map {

                $_ => $data->{$_}

            } grep {

                exists($data->{$_})

            } qw(networks volumes)

        });

    }
1;
