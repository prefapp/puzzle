package PrefApp::Puzzle::Commands;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::DB;
use PrefApp::Puzzle::Vault;
use PrefApp::Puzzle::Loader;
use PrefApp::Puzzle::TaskRunner;
use PrefApp::Puzzle::Compilation;
use PrefApp::Puzzle::Environment;
use PrefApp::Puzzle::DockerCompose;
use PrefApp::Puzzle::ServiceCompiler;

has(

    opts=>{},

    env=>undef,

    db=>undef,

    vault=>undef,

    loader=>undef,

    validServices=>undef,
    
    compilation=>undef,

    serviceCompiler=>undef,
);

sub initialize{

    $_[0]->SUPER::initialize(@_[1..$#_]);

    $_[0]->env(PrefApp::Puzzle::Environment->new(

        puzzle_compilation_path=>$_[0]->opts->{save}

    ));

    $_[0]->db(PrefApp::Puzzle::DB->new);
    $_[0]->vault(PrefApp::Puzzle::Vault->new);

    $_[0]->loader(
        
        PrefApp::Puzzle::Loader->new(

            refVault=>$_[0]->vault,

            basePath=>$_[0]->env->puzzle_source_path
        )

    );

    # we have to load the pieces
    $_[0]->c__loadPieces;


    # is there a compilation?
    if(-d $_[0]->env->puzzle_compilation_path){

        $_[0]->compilation(

            $_[0]->c__createCompilation()

        )
        
    }

    $_[0]->serviceCompiler(

        PrefApp::Puzzle::ServiceCompiler->new(

            refVault=>$_[0]->vault,

            refDB=>$_[0]->db,

            refCompilation=>$_[0]->compilation
        )
    );

    $_[0];
}


#
# External commands
#
sub end{
    my ($self) = @_;

    $self->env->store;
}

sub up{
    my ($self, @services) = @_;

    my $f_new;

    unless($self->compilation){

        $f_new = 1;

        $self->compilation(
            $self->c__createCompilation
        );

        $self->compilation->create;
    }
    
    my @services_list = $self->c__listValidServices(@services);

    my @created_services;
    my @upped_services;

    if($f_new){
        $self->c__compileService($_) foreach(@services_list);
    }
    else{
        foreach(@services_list){

            if(!$self->c__isServiceInstalled($_)){

                $self->error("The service $_ is not installed, we cannot up a service not installed in a working compilation");                

            }
        }
    
        @created_services = grep { !$self->c__isServiceInstalled($_)} @services_list;
        @upped_services = grep {$self->c__isServiceInstalled($_)} @services_list;

        $self->c__compileService($_) foreach(@created_services);
        $self->c__recompileService($_) foreach(@upped_services);
    }

    return $self if(grep {$_ eq '--only-build'} @_);

    # for every created service we have to fire the event on_create
    foreach my $service (@created_services){
        $self->c__fireEventForService($service, 'on_create');
    } 

    # we up the services
    foreach my $service (@services_list){
        $self->c__dockerForService($service)->up;
    }

    $self;
}


sub down{
    my ($self, @services) = @_;

    unless($self->compilation){
        $self->error("There is no working compilation");
    }

    my @services_list = $self->c__listInstalledServices(@services);

    foreach my $service (reverse @services_list){

        $self->info("Down of service ", $service);

        # fire event on_destroy
        $self->c__fireEventForService($service, "on_destroy");

        # down
        $self->c__dockerForService($service)->down; 
   
        # destroy service configuration
        $self->c__deleteServiceConfiguration($service);

        $self->info("Service $service is down");
    }

    # if the compilation is empty we erase the parent directory
    $self->c__deleteCompilation();
}

sub ps{
    my ($self, @services) = @_;

    unless($self->compilation){
        $self->error("There is no working compilation");
    }

    my @services_list = $self->c__listInstalledServices(@services);

    foreach my $service (@services_list){

        $self->info("Info: $service");

        $self->c__dockerForService($service)->ps;
    }
}

sub task{
    my ($self, $service, $task) = @_;

    unless($self->c__isServiceInstalled($service)){
        $self->error("$service is not installed");
    }

    $self->c__runTaskForService($service, $task);
}

sub taskList{
    my ($self, $service) = @_;

    unless($self->c__isServiceInstalled($service)){
        $self->error("$service is not installed");
    }

    $self->info("Task list for service $service");

    foreach my $tasks ($self->c__getPieceTasksLists($service)){

        $self->info("\t", $tasks->label);
    }
}

sub restart{

}

sub reset{

}

#
# Internal commands
#

    sub c__loadPieces{
        my ($self) = @_;

        unless($self->env->puzzle_source_path){
            $self->error("PUZZLE_SOURCE_PATH is not defined");
        }

        # establish the valid services
        # according to our box
        $self->validServices(

            { 

                map {

                    $_->service => $_->data->{weight}

                } map {

                    my ($piece) = $_ =~ /(\w+)\.yml$/;

                    $self->c__loadPiece($piece)

                } $self->c__listPieces

            }
        );

        # we load the pieces in order
        foreach my $v ($self->c__listValidServices){

            $self->c__dbPiece(

                $self->c__getPieceForService($v)

            );

        }
           
    }

    sub c__loadPiece{
        my ($self, $piece_name) = @_;

        my $piece = $self->loader
            
            ->loaderPiece()

                ->load(

                    $piece_name,

                    box=>$self->env->puzzle_box               

                );

        return $piece;
    }       

    sub c__listPieces{
        my ($self, $path) = @_;

        $path = $path || $self->env->puzzle_source_path . '/' . $self->env->puzzle_box;

        opendir(D, $path) || $self->fatal("Could not open pieces box: " . $!);
        
        my @pieces = grep { $_ =~ /\.yml$/} readdir(D);
        closedir(D);

        @pieces;

    }

    sub c__dbPiece{
        my ($self,$piece) = @_;

        $self->db->loadPiece($piece);
        
    }

    sub c__listValidServices{
        my ($self, @list) = @_;

        @list = (@list) ? @list : keys(%{$self->validServices});

        return sort {

            $self->validServices->{$b} <=> $self->validServices->{$a}

        } grep {

            $self->c__isValidService($_)

        } @list;
    }

    sub c__isValidService{

        exists $_[0]->validServices->{$_}

    }

    sub c__installedServices{
        my ($self, @list) = @_;

        @list = (@list) ? @list : $self->commands->getServices;

        $self->c__listValidServices(@list);

    }

    sub c__dockerForService{
        my ($self, $service) = @_;
    
        return PrefApp::Puzzle::DockerCompose->new(

            path=>$self->compilation->serviceComposePath($service)

        )
        
    }

    sub c__deleteServiceConfiguration{
        my ($self, $service) = @_;

        $self->compilation->deleteService($service);
    }

    sub c__createCompilation{
        my ($self) = @_;

        my $c = PrefApp::Puzzle::Compilation->new(

            path=>$self->env->puzzle_compilation_path,

            validServices=>[keys %{$self->validServices}],

        );

        if($self->serviceCompiler){
            $self->serviceCompiler->refCompilation($c);
        }       

        return $c;
    }

    sub c__compileService{
        my ($self, $service) = @_;

        $self->serviceCompiler->compile(

            $service,
    
            $self->c__getArgsToCompilation($service)

        );
    }

    sub c__recompileService{
        my ($self, $service) = @_;

        # we need to retrieve args from a service
        my $args = $self->compilation->getServiceCompilationArgs($service);

        # we destroy the original compilation of the service
        $self->compilation->deleteService($service);

        $self->serviceCompiler

            ->args($args)

            ->recompile(

                $service,

                $self->c__getArgsToCompilation($service)
            )
    }

    sub c__getArgsToCompilation{
        my ($self, $service) = @_;

        return (

            from => $self->opts->{from}->{$service}

        );
    }

    sub c__listInstalledServices{
        my ($self, @list) = @_;

        @list = (@list) ? @list : $self->c__listValidServices();

        grep {
            $self->c__isServiceInstalled($_);
        } @list
    }

    sub c__isServiceInstalled{
        my ($self, $service) = @_;

        $self->compilation->serviceInstalled($service);
    }

    sub c__deleteCompilation{
        my ($self) = @_;

        unless($self->c__listInstalledServices){
            $self->compilation->destroy;
        }
    }


    #
    # Commands for events
    #
    sub c__fireEventForService{
        my ($self, $service, $event) = @_;

        my $runner = $self->c__runnerForService($service);

        my @events = $self->c__getPieceForService(
        
            $service

        )->eventFired($event);

        $runner->runTasks($_) foreach(@events);
    }


    sub c__runTaskForService{
        my ($self, $service, $task) = @_;

        my $piece = $self->c__getPieceForService($service);

        if(my $task_object = $piece->getTasksFor($task)){

            $self->c__runTaskForService($service)->runTasks($task_object);

        }
        else{
            $self->error("$service does not have a task labelled $task");
        }
    }

    sub c__runnerForService{
        my ($self, $service) = @_;

        PrefApp::Puzzle::TaskRunner->new(

            service=>$service,

            dockerForService=>$self->c__dockerForService(

                $service

            )

        );
    }

    sub c__getPieceForService{
        my ($self, $service) = @_;

        $self->vault->get($service . '_piece');
    }

    sub c__getPieceTasksLists{
        my ($self, $service) = @_;

        values %{$self->c__getPieceForService($service)->tasks}
    }
1;
