package PrefApp::Puzzle::Loader;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::LoaderPiece;
use PrefApp::Puzzle::LoaderCompose;
use PrefApp::Puzzle::LoaderComposeConstruction;

sub LOADER_COMPOSE_CLASS{
    "PrefApp::Puzzle::LoaderCompose";
}

sub LOADER_COMPOSE_CONSTRUCTION_CLASS{
    "PrefApp::Puzzle::LoaderComposeConstruction"
}

sub LOADER_PIECE_CLASS{
    "PrefApp::Puzzle::LoaderPiece"
}

has(

    refVault=>undef,

    basePath =>undef,
);

sub initialize{
    $_[0]->SUPER::initialize(@_[1..$#_]);

    $_[0]->{basePath} = $_[0]->{basePath} || $ENV{PUZZLE_BASE_PATH};
}

sub load{
    $_[0]->__load(@_[1..$#_]);
}

sub loaderPiece{
    $_[0]->loader($_[0]->LOADER_PIECE_CLASS);
}

sub loaderCompose{
    $_[0]->loader($_[0]->LOADER_COMPOSE_CLASS);
}

sub createEntity{
    my ($self, $class, %args) = @_;

    $class->new(

        %args,
    
        refVault=>$self->refVault

    )->create
}

sub loader{
    my ($self, $class) = @_;

    $class->new(
            
        map {
    
            $_ =>$self->$_

        } qw(refVault basePath)
    
    )
}

sub __slurp{
    my ($self, $file) = @_;

    unless(-f $file){
        $self->fatal("Cannot find $file");
    }

    my $f;
    open($f, $file) || $self->fatal("Cannot open $file: $!");

    my $data = join('', <$f>);

    close $f;

    return $data;
}

1;
