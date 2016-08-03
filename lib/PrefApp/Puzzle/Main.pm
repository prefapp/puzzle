package PrefApp::Puzzle::Main;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use Eixo::Base::Data;

use Getopt::Long;

use PrefApp::Puzzle;
use PrefApp::Puzzle::Commands;

my $HELP_COMMANDS = &Eixo::Base::Data::getDataBySections(__PACKAGE__);

has(

    command=>undef,

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

    sub command_version{
    
        print "Puzzle version: " . $PrefApp::Puzzle::VERSION . "\n";
    }

    sub command_up{
        my ($self, @args) = @_; 

        $self->__parseOpts(
            'from=s@',
            'save=s',
            'box=s',
            'help',
            'only-build',
        );

        return $self->__printCommandHelp("up") if($self->opts->{help});

        $self->opts->{from} = {

            map {

                my ($service, $volume) = split(/\:/, $_);
            
                $service=>$volume

            } @{$_[0]->opts->{from} || []}
        };

        my $up_command = $self->{command} || "up";

        $self->__instantiateCommands->$up_command(

            @args

        )->end;
    }

    sub command_reload{
        my ($self, @args) = @_;

        $self->{command} = "reload";

        $self->command_up(@args);
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

        $self->__parseOpts(
            't_arg=s%',
        );

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

        if($t && $t =~ /\@/){
            $opts{$key} = [];
            $get_opts{$_} = $opts{$key};
        }
        elsif($t && $t =~ /\%/){
            $opts{$key} = {};
            $get_opts{$_} = $opts{$key};
        }
        else{
            $get_opts{$_} = sub { $opts{$_[0]} = $_[1] };
        }

    }

    Getopt::Long::Parser->new->getoptionsfromarray($self->argv, %get_opts);

    $self->opts(\%opts);

}

sub __printCommandHelp{
    my ($self, $command) = @_;
    
    print $HELP_COMMANDS->{$command};
}

1;

__DATA__

@@up

Usage: puzzle up (service1 service2...) [OPTIONS]

Creates/recreates a set of puzzle services

   --save           Save compilation to the specified location
   --from           Attachs a directory as the project working dir
   --only-build     Just creates the compilation
   --help           Prints this help
