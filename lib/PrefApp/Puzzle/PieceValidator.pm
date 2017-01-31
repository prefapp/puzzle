package PrefApp::Puzzle::PieceValidator;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(
    piece=>undef

);

sub NEEDED_SECTIONS{
    qw(
        weight
        application_containers
        origin
    )
}

sub validate :Sig(self, PrefApp::Puzzle::Piece){
    my ($self, $piece) = @_;

    $self->piece($piece);

    $self->__validateSections();
}

    sub __validateSections{
        my ($self) = @_;

        foreach($self->NEEDED_SECTIONS){

            unless(defined $self->piece->data->{$_}){
                $self->error("Piece " . $self->piece->alias . " lacks " . $_);
            }
        }

    }

1;
