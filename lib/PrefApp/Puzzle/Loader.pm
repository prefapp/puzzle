package PrefApp::Puzzle::Loader;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::LoaderPiece;
use PrefApp::Puzzle::LoaderCompose;
use PrefApp::Puzzle::LoaderComposeConstruction;
use PrefApp::Puzzle::LoaderPieceTasks;
use PrefApp::Puzzle::LoaderAddenda;

use PrefApp::Puzzle::EnvCompilation;
use PrefApp::Puzzle::ServiceCompilationArgs;
use PrefApp::Puzzle::CompilationInfo;


sub LOADER_COMPOSE_CLASS{
    "PrefApp::Puzzle::LoaderCompose";
}

sub LOADER_COMPOSE_CONSTRUCTION_CLASS{
    "PrefApp::Puzzle::LoaderComposeConstruction"
}

sub LOADER_PIECE_CLASS{
    "PrefApp::Puzzle::LoaderPiece"
}

sub LOADER_PIECE_TASKS_CLASS{
    "PrefApp::Puzzle::LoaderPieceTasks";
}

sub LOADER_ADDENDA_CLASS{
    "PrefApp::Puzzle::LoaderAddenda";
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

sub loaderAddenda{
    $_[0]->loader($_[0]->LOADER_ADDENDA_CLASS);
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

sub loadEnvCompilation{
    my ($self) = @_;

    $self->createEntity(

        "PrefApp::Puzzle::EnvCompilation"

    );
}

sub loadServicesCompilationArgs{
    my ($self) = @_;

    $self->createEntity(

        "PrefApp::Puzzle::ServiceCompilationArgs"

    );
}

sub loadCompilationInfo{
    my ($self) = @_;

    $self->createEntity(

        "PrefApp::Puzzle::CompilationInfo",

        t_creation=>time
    );
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
