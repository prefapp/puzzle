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
            'save=s'
        );

        $self->opts->{from} = {

            map {

                my ($service, $volume) = split(/\:/, $_);
            
                $service=>$volume

            } @{$_[0]->opts->{from} || []}
        };

        $self->__instantiateCommands->up(

            @args

        )->end;
        
    }

    sub command_down{
        my ($self, @args) = @_;

        $self->__instantiateCommands->down(
            @args
        );

    }

    sub command_ps{
        my ($self, @args) = @_;
    
        $self->__instantiateCommands->ps(
            @args
        );
    }
    
    sub command_task{
        my ($self, $service, $task) = @_;

        unless($service){
            $self->error("A service is needed");
        }

        # if a task is not provided, we list tasks
        my $command = ($task) ? "task" : "taskList";

        $self->__instantiateCommands->$command(

            $service,

            $task

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
    my %get_opts;

    foreach(@opts){

        my ($key, $t);

        if($_ =~ /\=/){ 
            ($key, $t) = split(/\=/, $_);
        }
        else{
            $key = $_;
        }

        if($t =~ /\@/){
            $opts{$key} = [];
            $get_opts{$_} = $opts{$key};
        }
        else{
            $get_opts{$_} = sub { $opts{$_[0]} = $_[1] };
        }

    }
    
    Getopt::Long::Parser->new->getoptionsfromarray($self->argv, %get_opts);

    $self->opts(\%opts);

}


1;
