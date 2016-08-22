package PrefApp::Puzzle::Environment;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use Hash::Merge;
use JSON::XS;

sub PATH{
    $ENV{HOME} . '/.puzzle';
}

my %ATTR;

has(
    
    %ATTR = (
    
        puzzle_box=>"pieces",

        puzzle_source_path=>undef,

        puzzle_compilation_path=>undef,

    )

);

sub initialize{
    my ($class, %data) = @_;
    
    my $original = $_[0]->__loadData();    

    my $env_data = $_[0]->__loadEnvData($original);


    my $merge_data = Hash::Merge->new('RIGHT_PRECEDENT')->merge(

        $original,

        $env_data,
    );

    # we don't need undefined environment values
    %data = map { 
                $_ => $data{$_} 
            } grep { 
                defined($data{$_})
            } keys(%data);

    return $class->SUPER::initialize(

        %{
            Hash::Merge->new('RIGHT_PRECEDENT')->merge(

                $merge_data,

                \%data
            )
        }

    );
}

sub store{

    my %data = %{$_[0]};

    open (F, '>', $_[0]->PATH) || $_[0]->fatal(
        "Couldn't open path for env storage: $!"
    );
    print F JSON::XS->new->encode(\%data);
    close F;
}


    sub __loadData{

        return {} unless(-f $_[0]->PATH);

        open F, $_[0]->PATH;
        my $d = join "", <F>;        
        close F;
         
        return JSON::XS->new->decode($d);   

    }   

    sub __loadEnvData{

        return {

            map {

                $_=>$ENV{uc($_)}

            } grep {

                defined($ENV{uc($_)})

            } keys(%{ATTR})

        }

    }


1;
