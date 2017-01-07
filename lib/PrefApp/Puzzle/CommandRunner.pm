package PrefApp::Puzzle::CommandRunner;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    service=>undef,

    dockerCommands=>undef,

    dockerForService=>undef,

    extra=>undef,
);

sub initialize{
    my ($self, @args) = @_;

    $self->SUPER::initialize(@args);

    $self->dockerForService(

        $self->__dockerForService($self->service)

    );

    $self;
}

sub runCommand :Sig(self, s){
    my ($self, $container, @command) = @_;

    eval{

        $self->dockerForService->run(

            $container,

            join(" ", @command)
    
        );
    };
    if($@){
        $self->fatal($@);
    }
}

sub __dockerForService{
    my ($self, $service) = @_;

    $self->dockerCommands->__dockerForService($service);
}

1;
