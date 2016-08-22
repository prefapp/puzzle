package PrefApp::Puzzle::Vault;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    refDB=>undef,

);

sub get{
    $_[0]->refDB->entities->{$_[1]};
}

sub addEntity :Sig(self, s, PrefApp::Puzzle::Entity){
    my ($self, $name, $entity) = @_;

    $self->refDB->entities->{$name} = $entity;
}

sub getPieces{
    my ($self) = @_;

    $self->hGrep(
        "PrefApp::Puzzle::Piece"
    )
}

sub hGrep{
    my ($self, $class) = @_;

    $self->__grep(sub {
        $_[0]->isa($class);
    });
}

sub __grep{
    my ($self, $f) = @_;

    return grep {$f->($_)} values(%{$self->refDB->entities});
}
