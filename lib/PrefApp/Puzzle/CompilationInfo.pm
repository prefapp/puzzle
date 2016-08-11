package PrefApp::Puzzle::CompilationInfo;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    t_creation=>undef,

    installed_services=>{},  

);

sub BUILD_ALIAS{
    "compilation_info";
}

sub FREEZE_KEYS{
    $_[0]->SUPER::FREEZE_KEYS,

    qw(
        t_creation
        installed_services
    )
}

sub serviceStatus :Sig(self, s){
    my ($self, $service) = @_;

    $self->installed_services->{$service};
}

sub serviceIsUp :Sig(self, s){
    my ($self, $service) = @_;

    $self->installed_services->{$service} = "up";
}

sub serviceIsDown :Sig(self, s){
    my ($self, $service) = @_;

    $self->installed_services->{$service} = "down";
}

1;
