package PrefApp::Puzzle::ServiceCompiler;

use strict;
use Eixo::Base::Clase qw(PrefApp::Puzzle::Base);

use JSON::XS;
use Hash::Merge;
use List::MoreUtils qw(uniq);  
use File::Basename qw(basename);

use PrefApp::Puzzle::ComposeWriterV1;
use PrefApp::Puzzle::ComposeWriterV2;

has(

    refVault=>undef,

    refDB=>undef,

    refCompilation=>undef,

    args=>{},

    compose_data=>{},

);

sub recompile{
    my ($self, $service, %args) = @_;

    my $merged_args = Hash::Merge

        ->new('RIGHT_PRECEDENT')

        ->merge(

            $self->args,

            \%args
        );


    $self->compile($service, %$merged_args);
    
}

sub compile{
    my ($self, $service, %args) = @_;

 #   $self->args(\%args);

    # we load the piece
    my $piece = $self->refVault->get($service . '_piece');

    # prepare the compose
    my $compose = $piece->compose || $self->fatal(
        "Piece " . $piece->alias. " is without compose"
    );

    my $compose_writer = $self->__getComposeWriterClass(

        $piece->composeVersion
    );

    my $docker_compose = $compose_writer

        ->new(

            %{$self}

        )->write($compose, $piece);


    # lets create the service structure
    $self->refCompilation->createService(

        $service,

        "docker-compose.yml" => $docker_compose,

        $self->__dependencies($compose)

    );
}

    sub __getComposeWriterClass{
        my ($self, $compose_version) = @_;

        if($compose_version eq 'V2'){
           return "PrefApp::Puzzle::ComposeWriterV2"
        }
        else{
           return "PrefApp::Puzzle::ComposeWriterV1"
        }
    }

    sub __dependencies{
        my ($self, $compose) = @_;

        my %dependencies;

        $dependencies{$_->path} = $_ 
            foreach($compose->getExtendedComposes);

        return map {

                basename($_->path) => PrefApp::Puzzle::YAML::Dump($_->data)

        } values(%dependencies);

    }

1;
1;
