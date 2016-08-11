package PrefApp::Puzzle::Process;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::Boot;

has(

    refVault=>undef,

    refDB=>undef,

    refCompilation=>undef,

    refEnv=>undef,

    loader=>undef,

    pieceCommands=>undef,

    compilationCommands=>undef,

    dockerCommands=>undef,

    eventCommands=>undef,

    opts=>undef,
);

sub initialize{
    my ($self, %args) = @_;

    $self->SUPER::initialize(%args);

    $self->__boot();
}
    sub __boot{
        my ($self, %args) = @_;

        my $boot = PrefApp::Puzzle::Boot->new(

            opts=>$self->opts,

        )->boot;

        $self->refEnv($boot->refEnv);
        $self->refVault($boot->vault);
        $self->refDB($boot->refDB);
        $self->refCompilation($boot->refCompilation);
        $self->loader($boot->loader);
        $self->pieceCommands($boot->pieceCommands);
        $self->compilationCommands($boot->compilationCommands);
        $self->dockerCommands($boot->dockerCommands);
        $self->eventCommands($boot->eventCommands);
    }

sub up{
    my ($self, @services) = @_;

#    @services = $self->__filterValidServices(@services);
#
#    unless(@services){
#        @services = $self->__servicesList;
#    }

    my $f_in_recompilation;

    if($f_in_recompilation = $self->refCompilation->exists){
        @services = $self->__recompilation(@services);
    }   
    else{
        @services = $self->__createCompilation(@services);
    }

    $self->saveContext;   


    # up on the services
    unless($self->opts->{"only-build"}){

        foreach my $service (@services){

            unless($f_in_recompilation){

                $self->eventCommands->fireEventForService(

                    "on_create",

                    $service

                );
            }

            $self->dockerCommands->upService($service);

        } 
    }

}

    sub __createCompilation{
        my ($self, @services) = @_;

        @services = $self->__filterValidServices(@services);

        # all services
        unless(@services){
            @services = $self->__servicesList;
        }

        $self->refCompilation->create;

        # we build the compilation services
        $self->compilationCommands->compileServices(
            @services
        );

        @services;
    }

    sub __recompilation{
        my ($self, @services) = @_;

        @services = $self->__getValidServicesOrAll(@services);

        foreach(@services){
            unless($self->compilationCommands->isServiceInstalled($_)){
                $self->error("service $_ is not installed on this compilation");
            }
        } 

        # we build the compilation services
        $self->compilationCommands->recompileServices(
            @services
        );

        @services;
    }


sub down{
    my ($self, @services) = @_;

    $self->error("There is no working compilation") 
        unless($self->refCompilation->exists);

    @services = $self->__getValidServicesOrAll(@services);

    # stop services
    foreach my $service (reverse @services){

        $self->info("Down of service $service");

        $self->dockerCommands->stopService($service);

        $self->eventCommands->fireEventForService(

            "on_destroy",

            $service,

            "--continue"

        );

        $self->compilationCommands->destroyServiceCompilation(
            $service
        );
    }

    # destroy de compilation if there are no remain services
    $self->compilationCommands->destroyCompilation();
}

sub ps{
    my ($self, @services) = @_;

    $self->error("There is no working compilation") 
        unless($self->refCompilation->exists);

    @services = $self->__getValidServicesOrAll(@services);
    
    foreach(@services){
        $self->dockerCommands->psService($_);
    }
}   

sub task{
    my ($self, $service, $task) = @_;

    unless($self->refCompilation->exists){
        $self->error("There is no working compilation");
    }

    $self->eventCommands->runTaskForService($task, $service);
}

sub __getValidServicesOrAll{
    my ($self, @services) = @_;

    @services = $self->compilationCommands->filterInstalledServices(@services);

    unless(@services){
        @services = $self->compilationCommands->allInstalledServices();
    }

    @services;
}


sub __servicesList{
    $_[0]->pieceCommands->validServices("--sorted");
}

sub __filterValidServices{
    my ($self, @services) = @_;

    @services = grep {
        $self->pieceCommands->isValidService($_)
    } @services;

    $self->pieceCommands->sortServices(@services);
}

sub saveContext{

    $_[0]->refCompilation->createDB(

        $_[0]->refDB

    );

    $_[0]->refEnv->store;
}

1;
