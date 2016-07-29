package PrefApp::Puzzle::Data;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use YAML::Syck;

has(
    sections=>{}
);

sub loadPiece{
    my ($self, $piece) = @_;

    $self->__loadConf($piece, 'exports');
    
    $self->__loadConf($piece, 'related');
}

sub __loadConf{
    my ($self, $entity, $source) = @_;

    my $conf = $entity->$source;

    foreach my $key (keys(%$conf)){

        my (@sections) = split(/\s*\+\s*/, $key);

        while (my ($k, $v) = each(%{$conf->{$key}})){

            foreach my $section (@sections){

                $self->set($section, $k, $v);

            }
        }
    }
}


sub exportSection{
    my ($self, $section) = @_;

    $_[0]->__getSection($section)
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
