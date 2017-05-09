package PrefApp::Puzzle::CompilationCommands;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::ServiceCompiler;
use PrefApp::Puzzle::merger::ComposeMerger;

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

    my @installed_services = $self->allInstalledServices;    

    return if(@installed_services > 0);

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

sub compileForInfo{
    my ($self) = @_;

    my @services = $self->allInstalledServices;    

    $self->__loadPieceToService($_, "self") foreach(@services);
    $self->__loadPieceToService($_, "related") foreach(@services);
    $self->__loadAddenda;
}

sub recompileServices{
    my ($self, @services) = @_;

    foreach my $service (@services){
        # delete original service compilation
        $self->refCompilation->deleteService($service);
    }

    my %services_dependencies = map { $_ => 1 } @services;

    my @services_dependencies = grep { !exists $services_dependencies{$_}}
        $self->allInstalledServices;

    $self->compileServices(\@services, \@services_dependencies);
}

sub compileServices{
    my ($self, $services, $services_dependencies, %args) = @_;

    my @services = @$services;

    # we need to create services tables
    $self->__loadPieceToService($_, "self") foreach(@services);
    $self->__loadPieceToService($_, "related") foreach(@services);

    # we load services dependencies
    if($services_dependencies){
        $self->__loadPieceToService($_, "related") foreach(@$services_dependencies);
    }

    # we load the addenda if present
    $self->__loadAddenda;

    # now we instantiate the service compiler with service compiling options

    my @services_compilers;

    foreach(@services){
        my $compiler = $self->__getServiceCompiler($_)->compile($_, %{$args{"--compiler_args"} || {}});

        if($args{"--return-compilers"}){
            push @services_compilers, $compiler->refComposeWriter;
        }
    }

    return @services_compilers if($args{"--return-compilers"});
}

sub compileAndMerge{
    my ($self, @services) = @_;

    my @services_compilers = $self->compileServices(

        \@services, 
    
        undef, 

        "--return-compilers" => 1,

        "--compiler_args" => {

            "--only-compile" => 1
        }
    );

    my $merger = PrefApp::Puzzle::merger::ComposeMerger->new;

    foreach(@services_compilers){

        $merger->addMergedPart(

            $_->merge

        );
    }

    return $merger->write;
    
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
