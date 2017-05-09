package PrefApp::Puzzle::merger::ComposerMergerV2;

use strict;
use Eixo::Base::Clase;

use Clone qw(clone); 

has(
    composer=>undef,

    __refs=>{},

    __refsSearch=>{},

    __composeData=>{},
);

sub GET_SERVICES{
    $_[0]->{__composeData}->{services}
}

sub GET_VOLUMES{
    $_[0]->{__composeData}->{volumes}
}

sub GET_NETWORKS{
    $_[0]->{__composeData}->{networks};
}

sub merge{
    my ($self) = @_;

    $self->{__composeData} = clone $self->composer->compose_data;
    #
    # Tenemos que prefijar todos los artefactos
    #

    #
    # Tenemos que prefijar todas las referencias a los artefactos
    #

    my $piece = $self->composer->pieceRef;

    my $prefix = $piece->alias;
     
    $_[0]->__createReferences($prefix);

    # 
    # We solve references
    # 
    $self->__resolveReferences();

    $self->__composeData;
} 

    sub __createReferences{
        my ($self, $prefix) = @_;
        
        # services' names
        my @references = keys(%{$self->composer->compose_data->{services}});   

        # networks' names
        push @references, keys(%{$self->composer->compose_data->{networks}});
        
        # volumes' names
        push @references, keys(%{$self->composer->compose_data->{volumes}});

        # for every reference we create a prefixed_reference
        $self->__refs->{$_} = $prefix . "_" . $_ foreach(@references); 

        # we compile a regex for searching
        $self->__refsSearch->{$_} = qr/($_)\:/ foreach(@references);
    }

    sub __resolveReferences{
        my ($self) = @_;
        
        #
        # We execute all the r__resolve's methods
        #    
        foreach my $m (grep { $_ =~ /^r__resolve/ } $self->methods(ref($self), 1)){
            $self->$m();
        }

        #
        # We change, at the end, the name of the services, volumes and networks
        #
        foreach my $k (keys %{$self->GET_SERVICES}){


            $self->__composeData->{services}->{$self->__refs->{$k}}  = $self->__composeData->{services}->{$k};

            delete($self->__composeData->{services}->{$k});
        }

        foreach my $v (keys %{$self->GET_VOLUMES || {}}){
    
            $self->__composeData->{volumes} = {} unless($self->__composeData->{volumes});

            $self->__composeData->{volumes}->{$self->__refs->{$v}}  = $self->__composeData->{volumes}->{$v};

            delete($self->__composeData->{volumes}->{$v});
        }

        foreach my $n (keys %{$self->GET_NETWORKS || {}}){

            $self->__composeData->{networks} = {} unless($self->__composeData->{networks});

            $self->__composeData->{networks}->{$self->__refs->{$n}}  = $self->__composeData->{networks}->{$n};

            delete($self->__composeData->{networks}->{$n});
        }
    }

        sub r__resolveLinks{
            my ($self) = @_;

            while(my ($service, $service_data) = each %{$self->GET_SERVICES}){

                next unless($service_data->{links});

                my $links = $service_data->{links};

                $links = [map { $self->__searchAndReplaceRef($_) } @$links];

                $service_data->{links} = $links;

            }
                       
        }

        sub r__resolveVolumes{
            my ($self) = @_;

            while(my ($service, $service_data) = each %{$self->GET_SERVICES}){

                next unless($service_data->{volumes});

                my $volumes = $service_data->{volumes};

                $volumes = [map { $self->__searchAndReplaceRef($_) } @$volumes];

                $service_data->{volumes} = $volumes;

            }

        }

        sub __searchAndReplaceRef{
            my ($self, $string) = @_;

            my %refsSearch = %{$self->__refsSearch};

            while(my ($ref, $reg) = each(%{refsSearch})){

                if($string =~ /$reg/){

                    my $resolvedRef = $self->__refs->{$ref};

                    $string =~ s/$1/$resolvedRef/;

                    goto END;
                }

            }

            END:
                return $string;
        }

1;
