package PrefApp::Puzzle::LoaderCompose;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Loader';

use PrefApp::Puzzle::Compose;

use YAML qw(Load);

sub COMPOSE_CLASS{
    "PrefApp::Puzzle::Compose";
}


sub __load{
    my ($self, $service, $name, %args) = @_;

    # first we load the file of the piece
    my $data = $self->__loadComposeData($name);

    # we create the piece
    my $compose = $self->createEntity(

        $self->COMPOSE_CLASS,

        service=>$service,

        data=>$data,

        %args

    );

    # we load the constructions
    $compose->constructions(

        $self->__loadConstructions($compose)

    );

    return $compose;
}

    sub __loadComposeData{
        my ($self, $name) = @_;

        Load(

            $self->__slurp(

                join(

                    "/",

                    $_[0]->basePath,

                    $name
                )
           ) 
        )
    }

    sub __loadConstructions{
        my ($self, $compose) = @_;

        my %constructions = map {

            $_ => $self->loader(

                $self->LOADER_COMPOSE_CONSTRUCTION_CLASS,


            )->load(

                $_,

                $compose->service,

                referer=>$compose->alias,

                data=>$compose->data->{$_}
            )
            

        } keys(%{$compose->data});

        \%constructions
    }

1;
