package PrefApp::Puzzle::Boot;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    refDB=>undef,

    args=>undef,
);


sub boot{
    my ($self, @args)  = @_; 
           
    foreach my $m (grep {$_ =~ /^__boot/ } $self->methods){

        $self->$m(@args);
    }
}

sub __bootDB{
    my ($self) = @_;

    
}


