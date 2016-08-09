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

sub allInstalledServices{
    my ($self) = @_;

    $self->filterInstalledServices(
        $self->pieceCommands->validServices
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

sub compileServices{
    my ($self, @services) = @_;

    # we need to create services tables
    $self->__loadPieceToService($_) foreach(@services);

    # we load the addenda if present
    $self->__loadAddenda;

    # now we instantiate the service compiler with service compiling options
    foreach(@services){
        $self->__getServiceCompiler($_)->compile($_);
    }
}

    sub __loadPieceToService :Sig(self, s){
        my ($self, $service) = @_;

        $self->pieceCommands->pieceToService(
            
            $service  . "_piece"
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
