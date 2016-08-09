package PrefApp::Puzzle::Process;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::Boot;

has(

    refVault=>undef,

    refDB=>undef,

    refCompilation=>undef,

    loader=>undef,

    pieceCommands=>undef,

    compilationCommands=>undef,

    dockerCommands=>undef,

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

        $self->refVault($boot->vault);
        $self->refDB($boot->refDB);
        $self->refCompilation($boot->refCompilation);
        $self->loader($boot->loader);
        $self->pieceCommands($boot->pieceCommands);
        $self->compilationCommands($boot->compilationCommands);
        $self->dockerCommands($boot->dockerCommands);
    }

sub up{
    my ($self, @services) = @_;

    @services = $self->__filterValidServices(@services);

    unless(@services){
        @services = $self->__servicesList;
    }

    if($self->refCompilation->exists){
        $self->__recompilation(@services);
    }   
    else{
        $self->__createCompilation(@services);
    }
 
    $self->saveContext;   
}

    sub __createCompilation{
        my ($self, @services) = @_;

        $self->refCompilation->create;

        # we build the compilation services
        $self->compilationCommands->compileServices(
            @services
        );
    }

    sub __recompilation{
        my ($self, @services) = @_;

        foreach(@services){
            unless($self->compilationCommands->isServiceInstalled($_)){
                $self->error("service $_ is not installed on this compilation");
            }
        } 

        # we build the compilation services
        $self->compilationCommands->compileServices(
            @services
        );

    }


sub down{
    my ($self, @services) = @_;

    $self->error("There is no working compilation") 
        unless($self->refCompilation->exists);

    @services = $self->__getValidServicesOrAll(@services);

    # stop services
    foreach(reverse @services){
        $self->dockerCommands->stopService($_);
    }

    # destroy de building
    foreach(@services){
        $self->compilationCommands->destroyServiceCompilation(
            $_
        );
    }
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

sub __getValidServicesOrAll{
    my ($self, @services) = @_;

    @services = $self->compilationCommands->filterInstalledServices(@services);

    unless(@services){
        @services = $self->compilationCommands->allInstalledServices();
    }
}


sub __servicesList{
    $_[0]->pieceCommands->validServices;
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
}

1;
