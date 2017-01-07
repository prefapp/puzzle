package PrefApp::Puzzle::ComposeWriterV2;

use strict;
use Eixo::Base::Clase "PrefApp::Puzzle::ComposeWriterV1";

sub write{

    my $docker_compose = $_[0]->SUPER::write(@_[1..$#_]);
 
    $docker_compose . "\nversion: '2'"
}

sub __write{

    my ($self, $compose, $piece) = @_;

    $self->SUPER::__write($compose, $piece);

    my $services = $self->compose_data;

    $self->{compose_data} = {

        services=>$services,
        
    };

    foreach(keys(%{$compose->artifacts})){

        $self->compose_data->{$_} = $compose->artifacts->{$_}

    }
    
}


1;
