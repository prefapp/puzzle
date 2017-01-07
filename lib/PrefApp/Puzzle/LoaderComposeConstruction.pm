package PrefApp::Puzzle::LoaderComposeConstruction;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Loader';

use PrefApp::Puzzle::ComposeConstruction;

sub COMPOSE_CONSTRUCTION_CLASS{
    "PrefApp::Puzzle::ComposeConstruction";
}


sub __load{
    my ($self, $name, $service, %args) = @_;

    my $construction = $self->createEntity(
        
        $self->COMPOSE_CONSTRUCTION_CLASS,

        name=>$name,

        service=>$service,

        %args

    );

    my ($compose, $base_service) = $self->__loadBaseCompose($construction, $args{path});

    if($compose){
        $construction->compose_base($compose);
        $construction->compose_base_as($base_service);
    }
    $construction;
}

    sub __loadBaseCompose{
        my ($self, $construction, $relativePath) = @_;

        return undef unless($construction->data->{extends});

        my $file = $construction->data->{extends}->{file};
        my $as = $construction->data->{extends}->{service};

        $file = $relativePath . "/" . $file if($relativePath);
        
        return ($self->loader(

            $self->LOADER_COMPOSE_CLASS,

        )->load(

            $construction->service,

            $file,
            
            referer=>$construction->alias,
            
        ), $as);
        
    }
    

1;
