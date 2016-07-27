package PrefApp::Puzzle::ServiceCompiler;

use strict;
use Eixo::Base::Clase qw(PrefApp::Puzzle::Base);

use YAML qw(Dump);
use Hash::Merge;
use List::MoreUtils qw(uniq);  
use File::Basename qw(basename);

use PrefApp::Puzzle::AttributeFinder;

has(

    refVault=>undef,

    refDB=>undef,

    refCompilation=>undef,

    args=>{},

    compose_data=>{},

);

sub compile{
    my ($self, $service, %args) = @_;

    $self->args(\%args);

    # we load the piece
    my $piece = $self->refVault->get($service . '_piece');

    # prepare the compose
    my $compose = $piece->compose;

    # let's compile every construction
    $self->__compileConstruction($_, $compose->constructions->{$_}, $piece) 
        foreach(keys(%{$compose->constructions}));   

    # lets create the service structure
    $self->refCompilation->createService(

        $service,

        "args" => $self->__exportArgs,

        "docker-compose.yml" => Dump($self->compose_data),

        $self->__dependencies($compose)

    );
}

    sub __compileConstruction{
        my ($self, $construction_name, $construction, $piece) = @_;

        my $data = $construction->data;

        $data->{environment} ||= {};

        # let's merge db relations in the environment
        $data->{environment} = Hash::Merge

            ->new('RIGHT_PRECEDENT')

            ->merge(

                $data->{environment},

                $self->refDB->exportSection($construction_name) || {}
            );

        # a project volume is needed?   
        if(my $from = $self->args->{from}){

            if(grep {$_ eq $construction_name} @{$piece->getApplicationContainers}){

                # We need a mount point
                if(my $mount_point = $self->__find($construction_name . '.working_dir', $piece)){
                    
                    $self->__mountVolume(

                        $construction, 

                        $from . ':' . $mount_point

                    );
                }
                else{
                    $self->error("Construction $construction_name has not established a working_dir, ".
                    
                        "a project volume cannot be defined"
                    );
                }
            }
    
        }
        

        # we copy the section
        $self->compose_data->{$construction_name} = $data;
    }

    sub __mountVolume{
        my ($self, $construction, $volume) = @_;
        
        $construction->data->{volumes} ||= [];

        push @{$construction->data->{volumes}}, $volume;
    }

    sub __find{

        PrefApp::Puzzle::AttributeFinder->new->find(

            $_[1], $_[2]

        )
    }

    sub __exportArgs{
        Dump($_[0]->args)
    }

    sub __dependencies{
        my ($self, $compose) = @_;

        my %dependencies;

        $dependencies{$_->path} = $_ 
            foreach($compose->getExtendedComposes);

        return map {

                basename($_->path) => Dump($_->data)

        } values(%dependencies);

    }

1;
