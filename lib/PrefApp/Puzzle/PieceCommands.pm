package PrefApp::Puzzle::PieceCommands;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    env=>undef,

    refDB=>undef,

    refVault=>undef,
    
    loader=>undef,

);

sub isValidService :Sig(self, s){
    my ($self, $service) = @_;
    
    grep {
        $_ eq $service
    } $self->validServices;
}

sub validServices{
    my ($self, $sort) = @_;

    my @valid_services = map {

        $_->service
    
    } $self->refVault->getPieces;

    return @valid_services unless($sort); 

    return $self->sortServices(@valid_services);   
}

sub sortServices{
    my ($self, @services) = @_;

    return @services unless(@services > 1);

    return sort { $self->refVault->get($a . "_piece")->weight <=> $self->refVault->get($b .'_piece')->weight } @services;
}

sub loadPieces{
    my ($self) = @_;

    unless($self->env->puzzle_source_path){
        $self->error("PUZZLE_SOURCE_PATH is not defined");
    }

    # establish the valid services
    # according to our box
    return { 

            map {

                $_->service => $_->data->{weight}

            } map {

                my ($piece) = $_ =~ /(\w+)\.yml$/;

                $self->loadPiece($piece)

            } $self->listPieces

    }
       
}

sub loadPiece{
    my ($self, $piece_name) = @_;

    my $piece = $self->loader
        
        ->loaderPiece()

            ->load(

                $piece_name,

                box=>$self->env->puzzle_box               

            );

    return $piece;
}       

sub listPieces{
    my ($self, $path) = @_;

    $path = $path || $self->env->puzzle_source_path . '/' . $self->env->puzzle_box;

    opendir(D, $path) || $self->fatal("Could not open pieces box ($path): " . $!);
    
    my @pieces = grep { $_ =~ /\.yml$/} readdir(D);
    closedir(D);

    @pieces;

}

sub pieceToService :Sig(self, s){
    my ($self, $piece_name) = @_;

    $self->refDB->loadPiece(

        $self->refVault->get($piece_name),

        "self"
    );

    $self->refDB->loadPiece(

        $self->refVault->get($piece_name),

        "related"
    );

}
1;
