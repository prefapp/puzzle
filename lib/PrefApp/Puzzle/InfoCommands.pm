package PrefApp::Puzzle::InfoCommands;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    refDB=>undef,

    refVault=>undef,
    
);

sub infoService :Sig(self, s){
    my ($self, $service) = @_;
    
    use Data::Dumper;
    print Dumper($self->refDB->services->{$service});
}

1;
