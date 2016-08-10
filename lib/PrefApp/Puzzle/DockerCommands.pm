package PrefApp::Puzzle::DockerCommands;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::DockerCompose;

has(

    env=>undef,

    refVault=>undef,

    refCompilation=>undef,

);

sub upService{
    my ($self, $service) = @_;
    
    $self->info("Starting service $service...");

    $self->__dockerForService($service)->up();

    $self->info("Service $service up");
}

sub psService{
    my ($self, @services) = @_;

    foreach my $service (@services){
    
        $self->info("Info: $service");

        $self->__dockerForService($service)->ps($service);
    }
}

sub stopService{
    my ($self, $service) = @_;

    $self->info("Stopping service $service");

    $self->__dockerForService($service)->stop($service);

    $self->info("Service $service stopped");
}

sub __dockerForService{
    my ($self, $service) = @_;

    return PrefApp::Puzzle::DockerCompose->new(

        path=>$self->refCompilation->serviceComposePath($service),
        
        env=>$self->refVault

                ->get('env')->env


    );
}

1;
