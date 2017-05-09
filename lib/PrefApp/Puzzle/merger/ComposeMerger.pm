package PrefApp::Puzzle::merger::ComposeMerger;

use strict;
use Eixo::Base::Clase qw(PrefApp::Puzzle::Base);

use PrefApp::Puzzle::YAML;

has(

    services=>{},

    volumes=>{},

    networks=>{},
    
    version=>"2"
);

sub write{
    my ($self) = @_;

    return PrefApp::Puzzle::YAML::Dump(
        
        {
            map {

                $_ => $self->{$_}

            } qw(services volumes networks version)
        }

    );
}

sub addMergedPart :Sig(self, HASH){
    my ($self, $part) = @_;

    foreach my $type (qw(services volumes networks)){
        
        if(my $data = $part->{$type}){

            while(my ($artifact, $artifact_data) = each(%$data)){
    
                if($self->{$type}->{$artifact}){
                    $self->error("Compose-merge: there is already a $type with name $artifact: merge impossible");
                }
                
                $self->{$type}->{$artifact} = $artifact_data;
            }
        }
    }
}

1;
