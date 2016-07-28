package PrefApp::Puzzle::DBService;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    service=>undef,

    sections=>{},

);

sub exportSection{
    my ($self, $section) = @_;

    $_[0]->__getSection($section)
}


sub loadData :Sig(self, HASH){
    my ($self, $data) = @_;

    foreach my $key (keys(%$data)){

        my (@sections) = split(/\s*\+\s*/, $key);

        while (my ($k, $v) = each(%{$data->{$key}})){

            foreach my $section (@sections){

                $self->set($section, $k, $v);

            }
        }
    }
}

sub set{
    my ($self, $section, $k, $v) = @_;

    $self->__getSection($section)->{$k} = $v;   
}

sub get{
    my ($self, $section, $k) = @_;

    $self->__getSection($section)->{$k};
}

    sub __getSection{

        $_[0]->sections->{$_[1]} ||= {};
    }


1;
