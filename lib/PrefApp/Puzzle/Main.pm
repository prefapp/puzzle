package PrefApp::Puzzle::Main;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use Eixo::Base::Data;

use Getopt::Long;

use PrefApp::Puzzle;
use PrefApp::Puzzle::Process;

use Cwd 'abs_path', 'cwd';

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

    sub command_update{
        my ($self, @args) = @_;

        $self->{command} = "update";

        $self->command_up(@args);
    }

    sub command_export{
        my ($self, @args) = @_;

        $self->__parseOpts(qw(
            help
            out=s    
        ));

        return $self->__printCommandHelp("export") if($self->opts->{help});

        $self->__instantiateCommands->export(
            @args
        );
    }

    sub command_export_compose{
        my ($self, @args) = @_;

        $self->__parseOpts(qw(
            help
        ));

        return $self->__printCommandHelp("export_compose") if($self->opts->{help});

        $self->__instantiateCommands->export_compose(
            @args
        );
    }

    sub command_import{
        my ($self, @args) = @_;

        $self->__parseOpts(qw(
            help
            save=s    
        ));

        return $self->__printCommandHelp("import") if($self->opts->{help});

        $self->opts->{importing} = 1;

        $self->__instantiateCommands->importPuzzle(
            @args
        );
    }

    sub command_down{
        my ($self, @args) = @_;

        $self->__parseOpts(qw(
            help
            destroy
        ));

        return $self->__printCommandHelp("down") if($self->opts->{help});

        $self->__instantiateCommands->down(
            @args
        );

    }

    sub command_ps{
        my ($self, @args) = @_;

        $self->__parseOpts(qw(
            help
        ));

        return $self->__printCommandHelp("ps") if($self->opts->{help});
    
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

    sub command_info{
        my ($self, @services) = @_;

        $self->__parseOpts(

            "help",
        );

        return $self->__printCommandHelp("info") if($self->opts->{help});

        $self->__instantiateCommands->infoPuzzle(
            
            @services
        );
    }

    sub command_generate{
        my ($self, @args) = @_;

        $self->__parseOpts(
            "help"
        );

        return $self->__printCommandHelp("generate") if($self->opts->{help} && @args == 1);

        return $self->__printCommandHelp("generate_piece") if($self->opts->{help} && $args[0] eq 'piece');

        $self->opts->{generating} = 1;

        return $self->__instantiateCommands->generate(
            @args
        );
    }

    sub command_run{
        my ($self, $service, $container, @args) = @_;

        $self->__parseOpts(
            "help"
        );

        return $self->__printCommandHelp("run") if($self->opts->{help});

        return $self->__instantiateCommands->run(

            $service,

            $container,

            @args
        );
    }

    sub command_start{
        my ($self,@services) = @_;

        $self->__parseOpts(
    
            "help"

        );

        return $self->__printCommandHelp("start") if($self->opts->{help});

        $self->__instantiateCommands->start(
            
            @services
        );
    }

    sub command_stop{
        my ($self,@services) = @_;

        $self->__parseOpts(
    
            "help"

        );

        return $self->__printCommandHelp("stop") if($self->opts->{help});

        $self->__instantiateCommands->stop(
            
            @services
        );

    }

sub __instantiateCommands{

    $_[0]->__setPath();

    PrefApp::Puzzle::Process->new(
        opts=>$_[0]->opts
    )
}

sub __setPath{
    my ($self) = @_;

    my $base_path = $self->opts->{path} || $ENV{PUZZLE_PROJECT_PATH} || abs_path(cwd());

    $ENV{PUZZLE_SOURCE_PATH} = $base_path;
            
    $ENV{PUZZLE_COMPILATION_PATH} = $base_path . '/run';
            
    $ENV{PUZZLE_BOX} = $self->opts->{box} || $ENV{PUZZLE_BOX} || 'dev_box';
    
}

sub __parseOpts{
    my ($self, @opts) = @_;

    my %opts;
    my %get_opts;

    # we always establish a set of necessary options
    push @opts, "path=s";
    push @opts, "box=s";

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

@@start

Usage: puzzle start (service1|service1:container1,container2 service2...) [OPTIONS]

Starts all or several containers of a service or services

@@stop

Usage: puzzle stop (service1|service1:container1,container2 service2...) [OPTIONS]

Stops all or several containers of a service or services


@@update

Usage: puzzle update(service1 service2...) [OPTIONS]

Pulls images from a service or services and the up

   --from           Attachs a directory as the project working dir
   --only-build     Just creates the compilation
   --add            Use an addenda for the compilation
   --help           Prints this help

@@up

Usage: puzzle up (service1 service2...) [OPTIONS]

Creates/recreates a set of puzzle services

   --from           Attachs a directory as the project working dir
   --only-build     Just creates the compilation
   --add            Use an addenda for the compilation
   --update         Recompilates services by reading the pieces and base composes, and check for updates in service images
   --help           Prints this help

@@task

Usage: puzzle task <service> <task_name> [OPTIONS]

Run <task_name> in a new service <service> container

   --arg            Argument to pass to task (can be declared multiple times)
   --help           Prints this help

If a <task_name> is not passed to the command a list of the tasks for the service are printed instead.


@@info

Usage: puzzle info (service1 service2 ...) [OPTIONS]

Shows information about conf and other parameters about services


@@down

Usage: puzzle down (service1 service ...) [OPTIONS]

Performs a down over a list of services 

    --destroy   Destroys the compilation 

@@ps

Usage: puzzle ps (service1 service2...) 

Performs a ps over a list of services

@@import

Usage: puzzle import import_path project_name <save_path>

Imports an exported puzzle database to create a compilation

@@export

Usage: puzzle export 

Exports a compilation to a puzzle database (defaults to ./compilation.puzzle)

    --out       Saves the exported database in the path/name specified

@@export_compose

Usage: puzzle export_compose [save_path]

Exports a compilation to a single docker-compose file 

@@generate

Usage: puzzle generate

Creates templates for different purposes

    piece     Creates a piece's template
    project   Creates a structure for a project

@@generate_piece

Usage: puzzle generate piece [box] [piece_name]

Creates a template for a piece

@@run

Usage: puzzle run service container command [args]

Run a command in a container whithin a service


