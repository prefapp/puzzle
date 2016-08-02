package PrefApp::Puzzle::Images;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    refVault=>undef,

    services=>{}

);

sub listImages :Sig(self, s){
    my ($self, $service) = @_;

    unless($self->services->{$service}){
        $self->fatal("Could not find information of images for service $service");
    }

    keys(%{$self->services->{$service}});
}

sub getServiceImages :Sig(self, s){
    my ($self, $service) = @_;

    my $piece = $self->refVault->get($service . "_piece") ||
        $self->fatal("Could not find piece for service $service");

    $self->__getImages($service, $piece->compose);
 
    $self;   
}
    sub __getImages{
        my ($self, $service, $compose) = @_;
        
        foreach my $c ($compose, $compose->getExtendedComposes){

            foreach my $construction (values %{$c->constructions}){

                my $image = $construction->data->{image};
     
                $self->__setImageForService($service, $image) if($image);

            }

        }

    }

        sub __setImageForService{
            my ($self, $service, $image) = @_;

            $self->services->{$service} ||= {};

            $self->services->{$service}->{$image}++;
        }

1;
