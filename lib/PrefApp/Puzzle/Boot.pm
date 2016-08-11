package PrefApp::Puzzle::Boot;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::DB;
use PrefApp::Puzzle::Environment;
use PrefApp::Puzzle::PieceCommands;
use PrefApp::Puzzle::CompilationCommands;
use PrefApp::Puzzle::DockerCommands;
use PrefApp::Puzzle::Loader;
use PrefApp::Puzzle::Vault;
use PrefApp::Puzzle::Compilation;

use PrefApp::Puzzle::EnvCompilation;
use PrefApp::Puzzle::ServiceCompilationArgs;

use PrefApp::Puzzle::EventCommands;

use PrefApp::Puzzle::CompilationInfo;

has(

    refEnv=>undef,

    refDB=>undef,

    refCompilation=>undef,

    opts=>undef,

    f_compilationExists=>undef,
);

sub initialize{
    my ($self, @args) = @_;

    $self->SUPER::initialize(@args);

    $_[0]->refEnv(PrefApp::Puzzle::Environment->new(

        puzzle_compilation_path=>$_[0]->opts->{save},

        puzzle_box=>$_[0]->opts->{box},

    ));

    $self->refDB(
        PrefApp::Puzzle::DB->new()
    );

    if(-e $self->compilationPath){

        $self->f_compilationExists(1);

    }
    
    $self->refCompilation(

        PrefApp::Puzzle::Compilation->new(

            path=>$self->compilationPath

        )
    );

    $self;
}


sub boot{
    my ($self, @args)  = @_; 
           
    foreach my $m (qw(

        __bootDB
        __bootPieces
        __bootSetValidServices
        __bootAddenda
        __bootEnvironment
        __bootCompilationInfo
        __bootServiceCompilationArgs

    )){

        $self->$m(@args);
    }

    $self;
}

sub __bootDB{
    my ($self) = @_;

    return unless($self->f_compilationExists);

    $self->refDB(
        $self->refCompilation->getDB
    );
}

sub __bootPieces{
    my ($self, @args) = @_;

    if(!$self->opts->{rebuild} && $self->f_compilationExists){
        return;
    }
   
    $self->pieceCommands->loadPieces()
}

sub __bootSetValidServices{
    my ($self) = @_;

    $self->refCompilation->validServices([

        $self->pieceCommands->validServices

    ]);
}

sub __bootAddenda{
    my ($self, @args) = @_;

    return undef unless($self->opts->{add});

    $self->loader->loaderAddenda->load(

        $self->opts->{add}
    );
}

sub __bootEnvironment{
    my ($self, @args) = @_;

    my $env = $self->vault->get('env');

    unless($env){
        $env = $self->loader->loadEnvCompilation;
    }
    
}

sub __bootCompilationInfo{
    my ($self, @args) = @_;


    unless($self->vault->get('compilation_info')){
        $self->loader->loadCompilationInfo;
    }
    
}


sub __bootServiceCompilationArgs{
    my ($self, @args) = @_;

    my $service_compilation_args = 

        $self->vault->get('services_compilation_args') ||
    
        $self->loader->loadServicesCompilationArgs;

    $service_compilation_args->mergeOpts($self->opts);
}

sub pieceCommands{

    PrefApp::Puzzle::PieceCommands->new(

        env=>$_[0]->refEnv,

        refDB=>$_[0]->refDB,

        loader=>$_[0]->loader,

        refVault=>$_[0]->vault,
    )
}

sub compilationCommands{

    PrefApp::Puzzle::CompilationCommands->new(

        env=>$_[0]->refEnv,

        refDB=>$_[0]->refDB,

        loader=>$_[0]->loader,

        refVault=>$_[0]->vault,

        pieceCommands=>$_[0]->pieceCommands,

        refCompilation=>$_[0]->refCompilation
    )
}

sub dockerCommands{

    PrefApp::Puzzle::DockerCommands->new(

        refVault=>$_[0]->vault,

        refCompilation=>$_[0]->refCompilation,
    );
}

sub eventCommands{
    
    PrefApp::Puzzle::EventCommands->new(

        refVault=>$_[0]->vault,

        refDB=>$_[0]->refDB,

        refCompilation=>$_[0]->refCompilation,

        opts=>$_[0]->opts,

        dockerCommands=>$_[0]->dockerCommands
    )
}

sub loader{

    PrefApp::Puzzle::Loader->new(
        
        refDB=>$_[0]->refDB,

        refVault=>$_[0]->vault,

        basePath=>$_[0]->refEnv->puzzle_source_path

    )
}

sub vault{

    PrefApp::Puzzle::Vault->new(
        refDB=>$_[0]->refDB
    )
}

sub compilationPath{
    $_[0]->refEnv->puzzle_compilation_path || 
        $_[0]->error("PUZZLE_COMPILATION_PATH not defined");
}

1;

