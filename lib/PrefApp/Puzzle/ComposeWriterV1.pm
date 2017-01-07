package PrefApp::Puzzle::ComposeWriterV1;

use strict;
use Eixo::Base::Clase "PrefApp::Puzzle::ComposeWriter";

use Hash::Merge;

sub __compileConstruction{
    my ($self, $construction_name, $construction, $piece) = @_;

    my $data = $construction->data;

    $data->{environment} ||= {};

    # let's merge db relations in the environment
    $data->{environment} = Hash::Merge

        ->new('RIGHT_PRECEDENT')

        ->merge(

            $data->{environment},

            $self->refDB->getSection($piece->service, $construction_name) || {}
        );

    # a project volume is needed?   
    if(my $from = $self->args->{from}){

        if(grep {$_ eq $construction_name} @{$piece->getApplicationContainers}){

            # We need a mount point
            if(my $mount_point = $self->__find($construction_name . '.working_dir', $piece)){

                # is already mounted?
                if($construction->from_mounted && $construction->from_mounted ne $from){

                    $self->__umountVolume(

                        $construction, 

                        $construction->from_mounted . ':' . $mount_point

                    );
                }

                unless($construction->from_mounted && $construction->from_mounted eq $from){

                 $self->__mountVolume(

                     $construction, 

                     $from . ':' . $mount_point

                 );

                }

                $construction->from_mounted($from);
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

1;
