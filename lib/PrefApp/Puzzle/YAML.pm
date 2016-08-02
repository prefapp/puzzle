package PrefApp::Puzzle::YAML;
use strict;

use YAML::Syck qw();

sub Load{

    __mergekeys(
        YAML::Syck::Load(
            $_[0]
        )
    )
}

sub Dump {

    YAML::Syck::Dump(@_);
}

sub LoadFile{
    __mergekeys(
        YAML::Syck::LoadFile(
            $_[0]
        )
    )
}

sub DumpFile {

    YAML::Syck::DumpFile(
        @_
    )
}


sub __mergekeys{
    
    my ($ref) = @_;
    
    my $type = ref $ref;
    
    if ($type eq 'HASH'){
        my $tmphref = $ref->{'<<'};
        if ($tmphref){
            die "Merge key does not support merging non-hashmaps"
                unless (ref $tmphref eq 'HASH');

            my %tmphash = %$tmphref;
            delete $ref->{'<<'};
            %$ref = (%tmphash, %$ref);
        }

        __mergekeys($_) for (values %$ref);
    }
    elsif ($type eq 'ARRAY'){
        __mergekeys($_) for (@$ref);
    }

    return $ref;
}

1;
