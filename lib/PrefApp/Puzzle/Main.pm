package PrefApp::Puzzle::Main;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use Getopt::Long;

use PrefApp::Puzzle::Commands;

has(
    opts=>{},

    argv=>[],
);

sub run{
    my ($self, $command, @args) = @_;

    my $code;

    unless($code = $self->can('command_' . $command)){
        
        $self->error("Unknown command: $command");
    }
    
    $self->$code(@args);
}

    sub command_up{
        my ($self, @args) = @_; 

        $self->__parseOpts(
            'from=s@',
        );

        $self->__instantiateCommands->up(
            @args
        )
        
    }

    sub command_down{
        my ($self, @args) = @_;

        $self->__instantiateCommands->down(
            @args
        );

    }

sub __instantiateCommands{
    
    PrefApp::Puzzle::Commands->new(
        opts=>$_[0]->opts
    )
}

sub __parseOpts{
    my ($self, @opts) = @_;

    my %opts;
    my $get_opts ={};

    foreach(@opts){

        my ($key, $t) = split(/\=/, $_);

        if($t =~ /\@/){
            $opts{$key} = [];
        }
        else{
            $opts{$key} = '';
        }

        $get_opts->{$_} = $opts{$key};
    }
    
    Getopt::Long::Parser->new->getoptionsfromarray($self->argv, %$get_opts);

    $self->opts(\%opts);

}


1;
