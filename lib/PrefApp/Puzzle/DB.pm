package PrefApp::Puzzle::DB;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::DBService;

has(

    services=>{}

);


sub getSection :Sig(self, s, s){
    my ($self, $service, $section) = @_;

    $self->services->{$service} &&

        $self->services->{$service}->exportSection($section)
}

sub loadPiece :Sig(self, PrefApp::Puzzle::Piece){
    my ($self, $piece) = @_;

    my $data = $piece->exports;

    foreach my $service (keys(%$data)){

        my $service_name = ($service eq '_self') ? 

                $piece->service : $service;

        $self->loadServiceDb($service_name)->loadData(
            $data->{$service}
        );

    }
}

sub loadServiceDb{
    my ($self, $service) = @_;

    $self->{services}->{$service} ||= PrefApp::Puzzle::DBService->new(

        service=>$service

    )
}
