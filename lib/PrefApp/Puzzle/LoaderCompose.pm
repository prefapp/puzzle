package PrefApp::Puzzle::LoaderCompose;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Loader';

use File::Basename qw(fileparse);
use PrefApp::Puzzle::Compose;

use PrefApp::Puzzle::YAML;

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

        path=>$self->__calculateComposePath($name),

        %args

    );

    # we load the constructions
    $compose->constructions(

        $self->__loadConstructions($compose, $name)

    );

    return $compose;
}

    sub __loadComposeData{
        my ($self, $name) = @_;

        PrefApp::Puzzle::YAML::Load(

            $self->__slurp(
                $self->__calculateComposePath($name)
            ) 
        )
    }

    sub __calculateComposePath{
        my ($self, $name) = @_;

        join(

            "/",

            $self->basePath,
    
            $name

        )
    
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

                data=>$compose->data->{$_},

                path=>$relativePath
            )
            

        } keys(%{$compose->data});

        \%constructions
    }

1;
