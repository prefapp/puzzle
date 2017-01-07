package PrefApp::Puzzle::LoaderCompose;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Loader';

use File::Basename qw(fileparse);
use PrefApp::Puzzle::Compose;

use PrefApp::Puzzle::YAML;

use PrefApp::Puzzle::LoaderComposeV1;
use PrefApp::Puzzle::LoaderComposeV2;

sub COMPOSE_CLASS{
    "PrefApp::Puzzle::Compose";
}

sub COMPOSE_LOADER_V1{
    "PrefApp::Puzzle::LoaderComposeV1";
}

sub COMPOSE_LOADER_V2{
    "PrefApp::Puzzle::LoaderComposeV2";
}

sub __load{
    my ($self, $service, $name, %args) = @_;

    # first we load the file of the piece
    my $data;

    eval{

        $data  = $self->__loadComposeData($name);

        $self->__adaptarComposeAVersion($data);

    };
    if($@){
        $self->fatal("Loading compose $name : " . $@);
    }

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

    # We load additional keys (if necessary)
    if($self->can("__loadAdditionalArtifacts")){
        $self->__loadAdditionalArtifacts($compose, $data);
    }

    return $compose;
}

    sub __adaptarComposeAVersion{
        my ($self, $data) = @_;

        unless($data->{version}){
            return bless($self, $self->COMPOSE_LOADER_V1);
        }
        
        if($data->{version} eq '2'){
            return bless($self, $self->COMPOSE_LOADER_V2);
        }
        else{
            $self->fatal("UNSUPPORTED DOCKER_COMPOSE VERSION " . $data->{version});
        }
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

1;
