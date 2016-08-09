package PrefApp::Puzzle::ServiceCompilationArgs;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

use Storable qw(thaw);

has(

    services=>{}

);

sub FREEZE_KEYS{
    qw(
        alias
        services
    )
}

sub BUILD_ALIAS{
    "services_compilation_args"
}

sub initialize{
    my ($self, %args) = @_;

    $self->SUPER::initialize(%args);

    $self->__initializeOpts($args{opts} || {});

    $self;
}

sub mergeOpts{
    my ($self, $opts) = @_;

    $self->__initializeOpts($opts);
}

    sub __initializeOpts{
        my ($self, $opts) = @_;

        $self->__initializeFromOpts($opts->{from});
    }   

        sub __initializeFromOpts{
            my ($self, $froms) = @_;

            $self->__setServiceArg($_, "from",$froms->{$_})
                    foreach(keys(%$froms));
        }

    sub __setServiceArg{
        my ($self, $service_name, $key, $value) = @_;

        $self->services->{$service_name} ||= {};

        $self->services->{$service_name}->{$key} = $value;
    }

sub getServiceArgs{
    $_[0]->services->{$_[1]};
}


1;
