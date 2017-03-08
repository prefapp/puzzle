package PrefApp::Puzzle::DockerCommands;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::DockerCompose;

has(

    env=>undef,

    refVault=>undef,

    refCompilation=>undef,

);

sub pullService{
    my ($self, $service) = @_;

    $self->info("Pulling images from service $service");

    $self->__dockerForService($service)->composePull;

    $self->info("Images from $service pulled");
}

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

sub downService{
    my ($self, $service) = @_;

    $self->info("Down service $service");

    $self->__dockerForService($service)->down();

    $self->info("Service $service is down");
}

sub stopService{
    my ($self, $service) = @_;

    $self->info("Stopping service $service");

    $self->__dockerForService($service)->stop();

    $self->info("Service $service stopped\n");
}

sub startService{
    my ($self, $service) = @_;

    $self->info("Starting service $service");

    $self->__dockerForService($service)->start();

    $self->info("Service $service started\n");
}

sub startServiceContainers{
    my ($self, $service, @containers) = @_;

    $self->error("NOT IMPLEMENTED YET");

    #$self->info("Starting service $service". '\'s (' . join(',', @containers) . ")");

    #$self->__dockerForService($service)->start($service, @containers);

    #$self->info("Service $service\'s containers started");
}

sub stopServiceContainers{
    my ($self, $service, @containers) = @_;

    $self->error("NOT IMPLEMENTED YET");

    #$self->info("Stopping service $service". '\'s (' . join(',', @containers) . ")");

    #$self->__dockerForService($service)->stop($service, @containers);

    #$self->info("Service $service\'s containers stopped");
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
