package PrefApp::Puzzle::CompilationCommands;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::ServiceCompiler;

has(

    env=>undef,

    refDB=>undef,

    refVault=>undef,

    refCompilation=>undef, 
   
    loader=>undef,

    pieceCommands=>undef,

);

sub destroyCompilation{
    my ($self, @opts) = @_;

    return $self->refCompilation->destroy 
        if(grep {$_ eq '--all'} @_);    

    return if($_[0]->allInstalledServices);

    $self->refCompilation->destroy 

}

sub allInstalledServices{
    my ($self) = @_;

    $self->filterInstalledServices(
        $self->pieceCommands->validServices("--sorted")
    );
}

sub filterInstalledServices{
    my ($self, @services) = @_;

    $self->pieceCommands->sortServices(

        grep {

            $self->isServiceInstalled($_)

        } @services

    );
}

sub isServiceInstalled{
    $_[0]->refCompilation->serviceInstalled($_[1]);
}

sub destroyServiceCompilation{
    my ($self, $service) = @_;

    unless($self->isServiceInstalled($service)){

        $self->fatal("Service $service is not installed: there is no compilation to destroy");
    }

    $self->refCompilation->deleteService($service);
}

sub recompileServices{
    my ($self, @services) = @_;

    foreach my $service (@services){
        # delete original service compilation
        $self->refCompilation->deleteService($service);
    }

    $self->compileServices(@services);
}

sub compileServices{
    my ($self, @services) = @_;

    # we need to create services tables
    $self->__loadPieceToService($_, "self") foreach(@services);
    $self->__loadPieceToService($_, "related") foreach(@services);

    # we load the addenda if present
    $self->__loadAddenda;

    # now we instantiate the service compiler with service compiling options
    foreach(@services){
        $self->__getServiceCompiler($_)->compile($_);
    }
}

    sub __loadPieceToService :Sig(self, s,s){
        my ($self, $service, $section) = @_;

        $self->pieceCommands->pieceToService(
            
            $service  . "_piece",

            $section
        );
    }

    sub __loadAddenda{
        my ($self) = @_;

        my $addenda = $self->refVault->get('addenda');

        return unless($addenda);

        $self->refDB->loadAddenda($addenda);
    }

    sub __getServiceCompiler{
        my ($self, $service) = @_;

        PrefApp::Puzzle::ServiceCompiler->new(

            refVault=>$self->refVault,

            refDB=>$self->refDB,

            refCompilation=>$self->refCompilation,
        
            args=>$self->__getServiceCompilationArgs($service)

        )

    }

    sub __getServiceCompilationArgs{
        my ($self, $service) = @_;

        $self->refVault

            ->get('services_compilation_args')

                ->getServiceArgs($service) || {}
    }
1;
