package PrefApp::Puzzle::Exporter;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use Storable;
use File::Basename qw(basename);

has(

    refDB=>undef,

);

sub export :Sig(self, s){
    my ($self, $path) = @_;

    my $path_exportation;

    if(-d $path){
        $path_exportation .= "/export.puzzle"
    }else{

        my $name = basename($path);        

        $name .= ".puzzle" unless($name =~ /\.puzzle$/);

        $path_exportation = dirname($path) . '/' . $name;
        
    }

    store ($self->refDB, $path_exportation);

    $self->info("Compilation exported to $path_exportation");
}

sub import :Sig(self, s){
    my ($self,$path) = @_;

    unless(-f $path){
        $self->error("Puzzle file not found in $path");
    }

    $self->{refDB} = retrieve $path;
}

1;
