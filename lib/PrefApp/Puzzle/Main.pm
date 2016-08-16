package PrefApp::Puzzle::Main;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use Eixo::Base::Data;

use Getopt::Long;

use PrefApp::Puzzle;
use PrefApp::Puzzle::Process;

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
            'source=s',
            'add=s',
            'rebuild',
            'help',
            'only-build',
        );

        my $up_command = $self->{command} || "up";

        return $self->__printCommandHelp($up_command) if($self->opts->{help});

        if(my $source = $self->opts->{source}){
            $ENV{PUZZLE_SOURCE_PATH} = $source;
        }

        if(my $path_compilation = $self->opts->{save}){
            $ENV{PUZZLE_COMPILATION_PATH} = $path_compilation;
        }

        if(my $box = $self->opts->{box}){
            $ENV{PUZZLE_BOX} = $box;
        }

        $self->opts->{from} = {

            map {

                my ($service, $volume) = split(/\:/, $_);
            
                $service=>$volume

            } @{$_[0]->opts->{from} || []}
        };


        $self->__instantiateCommands->$up_command(

            @args

        );
    }

    sub command_reload{
        my ($self, @args) = @_;

        $self->{command} = "reload";

        $self->command_up(@args);
    }

    sub command_export{
        my ($self, @args) = @_;

        $self->__parseOpts(qw(
            out=s    
        ));

        $self->__instantiateCommands->export(
            @args
        );
    }

    sub command_import{
        my ($self, @args) = @_;

        $self->__parseOpts(qw(
            save=s    
        ));

        $self->opts->{importing} = 1;

        $self->__instantiateCommands->importPuzzle(
            @args
        );
    }

    sub command_down{
        my ($self, @args) = @_;

        $self->__parseOpts(qw(
            help
        ));

        return $self->__printCommandHelp("up") if($self->opts->{help});

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
            'arg=s%',
            'help',
        );

        return $self->__printCommandHelp("task") if($self->opts->{help});

        # if a task is not provided, we list tasks
        my $command = ($task) ? "task" : "taskList";

        $self->__instantiateCommands->$command(

            $service,

            $task

        );
        
    }

sub __instantiateCommands{
    
    PrefApp::Puzzle::Process->new(
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

@@reload

Usage: puzzle reload (service1 service2...) [OPTIONS]

Pulls images from a service or services and the up

   --save           Save compilation to the specified location
   --from           Attachs a directory as the project working dir
   --only-build     Just creates the compilation
   --add            Use an addenda for the compilation
   --help           Prints this help

@@up

Usage: puzzle up (service1 service2...) [OPTIONS]

Creates/recreates a set of puzzle services

   --save           Save compilation to the specified location
   --from           Attachs a directory as the project working dir
   --only-build     Just creates the compilation
   --add            Use an addenda for the compilation
   --rebuild        Recompilates services by reading the pieces and base composes anew
   --help           Prints this help

@@task

Usage: puzzle task <service> <task_name> [OPTIONS]

Run <task_name> in a new service <service> container

   --arg            Argument to pass to task (can be declared multiple times)
   --help           Prints this help

@@info

Usage: puzzle info (service1 service2 ...) [OPTIONS]

Shows information about conf and other parameters about services


