package PrefApp::Puzzle::Generator;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

my $TEMPLATES = &Eixo::Base::Data::getDataBySections(__PACKAGE__);

sub projectStructure :Sig(self, s){
    my ($self, $project, $path) = @_;

    $path = $path || $ENV{HOME};

    $self->__mkdir($path . '/' . $project, 'die-if-exists');
    
    $self->__mkdir($path . '/' . $project . '/' . $_) foreach(qw(

        run
        compose
        dev_box
        prod_box
    ));
}

    sub __mkdir :Sig(self, s){
        my ($self, $path, $die_if_exists) = @_;

        if(-d $path){
            if($die_if_exists){
                $self->error("Path $path already exists");
            }
            else{
                return;
            }
        }

        mkdir($path) || $self->error("Path $path couldn't be created: $!");

        print "mkdir : $path\n";
    }


sub template{
    my ($self, $type) = @_;

    unless(defined($TEMPLATES->{$type})){

        $self->error("TEMPLATE type '$type' is unknown");
    }

    return $TEMPLATES->{$type};

}


1;

__DATA__

@@piece

# the relative path to the docker-compose this piece controls
origin: "" 

# a list of the runnable containers
application_containers: []

# priority of this piece in bootstrapping/stopping process
weight: 0

# a list of environment variables this piece establishes
overrides:
  _self: {}

# events to control by sending tasks
events: {}

# tasks defined in this piece
tasks: {}
