package PrefApp::Puzzle::Process;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::Boot;
use PrefApp::Puzzle::Exporter;

use PrefApp::Puzzle::Environment;
use PrefApp::Puzzle::Compilation;

use PrefApp::Puzzle::Generator;

use PrefApp::Puzzle::CommandRunner;

has(

    refVault=>undef,

    refDB=>undef,

    refCompilation=>undef,

    refEnv=>undef,

    loader=>undef,

    pieceCommands=>undef,

    compilationCommands=>undef,

    dockerCommands=>undef,

    eventCommands=>undef,

    infoCommands=>undef,

    opts=>undef,
);

sub initialize{
    my ($self, %args) = @_;

    $self->SUPER::initialize(%args);

    $self->__boot() unless(

        $self->opts->{importing} ||

        $self->opts->{generating} 

    );
}
    sub __boot{
        my ($self, %args) = @_;

        my $boot = PrefApp::Puzzle::Boot->new(

            opts=>$self->opts,

        )->boot;

        $self->refEnv($boot->refEnv);
        $self->refVault($boot->vault);
        $self->refDB($boot->refDB);
        $self->refCompilation($boot->refCompilation);
        $self->loader($boot->loader);
        $self->pieceCommands($boot->pieceCommands);
        $self->compilationCommands($boot->compilationCommands);
        $self->dockerCommands($boot->dockerCommands);
        $self->infoCommands($boot->infoCommands);
        $self->eventCommands($boot->eventCommands);
    }

sub update{
    my ($self, @services) = @_;

    @services = $self->__getValidServicesOrAll(@services);

    $self->error("There is no working compilation") 
        unless($self->refCompilation->exists);

    foreach my $service (@services){
        $self->dockerCommands->pullService($service);
    }

    $self->up(@services);
}

sub up{
    my ($self, @services) = @_;

#    @services = $self->__filterValidServices(@services);
#
#    unless(@services){
#        @services = $self->__servicesList;
#    }

    my $f_in_recompilation;

    if($f_in_recompilation = $self->refCompilation->exists){
        @services = $self->__recompilation(@services);
    }   
    else{
        @services = $self->__createCompilation(@services);
    }

    $self->compilationInfo->serviceIsUp($_) foreach(@services);

    $self->saveContext unless($self->opts->{"do-not-save-context"});   


    # up on the services
    unless($self->opts->{"only-build"}){

        foreach my $service (@services){

            unless($f_in_recompilation){

                $self->eventCommands->fireEventForService(

                    "on_create",

                    $service

                );
            }

            $self->dockerCommands->upService($service);

            unless($f_in_recompilation){

                $self->eventCommands->fireEventForService(

                    "on_up",

                    $service

                );

            }

        } 
    }

}

    sub __createCompilation{
        my ($self, @services) = @_;

        @services = $self->__filterValidServices(@services);

        # all services
        unless(@services){
            @services = $self->__servicesList;
        }

        $self->refCompilation->create;

        # we build the compilation services
        $self->compilationCommands->compileServices(
            \@services
        );

        @services;
    }

    sub __recompilation{
        my ($self, @services) = @_;

        @services = $self->__getValidServicesOrAll(@services);


        foreach(@services){
            unless($self->compilationCommands->isServiceInstalled($_)){
                $self->error("service $_ is not installed on this compilation");
            }
        } 

        # we build the compilation services
        $self->compilationCommands->recompileServices(
            @services,
        );


        @services;
    }


sub down{
    my ($self, @services) = @_;

    $self->error("There is no working compilation") 
        unless($self->refCompilation->exists);

    @services = $self->__getValidServicesOrAll(@services);

    $self->compilationInfo->serviceIsDown($_) foreach(@services);

    # stop services
    foreach my $service (reverse @services){

        $self->info("Down of service $service");

        $self->eventCommands->fireEventForService(

            "on_destroy",

            $service,

            "--continue"

        );

        $self->dockerCommands->downService($service);

        $self->compilationCommands->destroyServiceCompilation(

            $service

        ) if($self->opts->{destroy});
    }

    # destroy de compilation if there are no remain services
    $self->compilationCommands->destroyCompilation() if($self->opts->{destroy});
}

sub ps{
    my ($self, @services) = @_;

    $self->error("There is no working compilation") 
        unless($self->refCompilation->exists);

    @services = $self->__getValidServicesOrAll(@services);
    
    foreach(@services){
        $self->dockerCommands->psService($_);
    }
}   

sub task{
    my ($self, $service, $task) = @_;

    unless($self->refCompilation->exists){
        $self->error("There is no working compilation");
    }

    unless($self->compilationCommands->isServiceInstalled($service)){
        $self->error("Service $service is not installed");
    }

    $self->eventCommands->runTaskForService($task, $service);
}

sub taskList{
    my ($self, $service) = @_;

    unless($self->refCompilation->exists){
        $self->error("There is no working compilation");
    }

    unless($self->compilationCommands->isServiceInstalled($service)){
        $self->error("Service $service is not installed");
    }

    my $tasks = $self->eventCommands->getTasksForService($service);

    print "Tasks for $service:\n";
    print "  - $_\n" foreach(@$tasks);
}

sub export{
    my ($self) = @_;

    my $path = $self->opts->{"out"} || "./compilation.puzzle";

#    $self->opts->{"do-not-save-context"} = 1;
#    $self->opts->{"only-build"} = 1;
#
#    # we need to create a build path 
#    $self->refEnv->puzzle_compilation_path(
#        "/tmp/compilation_" . int(rand(99999))
#    );
#
#    $self->refCompilation->path($self->refEnv->puzzle_compilation_path);
#
#    # now we create a new compilation
#    $self->up(@services);

    unless($self->refCompilation->exists){
        $self->error("There is no working compilation");
    }

    # we export it to the path
    $self->exporter->exportPuzzle($path);
}

sub infoPuzzle{
    my ($self, @services) = @_;

    unless($self->refCompilation->exists){
        $self->error("There is no working compilation");
    }

    @services = $self->__getValidServicesOrAll(@services);

    $self->compilationCommands->compileForInfo();

    $self->infoCommands->infoService($_) foreach(@services);
}

#
# Run a command in a container
#
sub run{
    my ($self, $service, $container, @command) = @_;

    PrefApp::Puzzle::CommandRunner->new(

        service=>$service,

        dockerCommands=>$self->dockerCommands,

    )->runCommand($container, @command);
}

sub __getValidServicesOrAll{
    my ($self, @services) = @_;

    @services = $self->compilationCommands->filterInstalledServices(@services);

    unless(@services){
        @services = $self->compilationCommands->allInstalledServices();
    }

    @services;
}


sub __servicesList{
    $_[0]->pieceCommands->validServices("--sorted");
}

sub __filterValidServices{
    my ($self, @services) = @_;

    @services = grep {
        $self->pieceCommands->isValidService($_)
    } @services;

    $self->pieceCommands->sortServices(@services);
}

sub saveContext{

    $_[0]->refCompilation->createDB(

        $_[0]->refDB

    );

    $_[0]->refEnv->store;
}

sub compilationInfo{
    $_[0]->refVault->get('compilation_info')
}

sub exporter{
    
    PrefApp::Puzzle::Exporter->new(

        refDB=>$_[0]->refDB

    );
}

sub importPuzzle{
    my ($self, $import_path, $project_name, $save_path) = @_;

    unless(-f $import_path){
        $self->error("Puzzle file \'$import_path\' does not exist");
    }

    unless($project_name){
        $self->error("Puzzle import needs a project name");
    }

    $save_path = $save_path  || ".";

    $self->refEnv(
        PrefApp::Puzzle::Environment->new()
    ); 

    $self->generate("project", $project_name, $save_path);

    my $db = $self->exporter->importPuzzle($import_path);

    my $compilation = PrefApp::Puzzle::Compilation->new(
        path => join("/", $save_path, $project_name, "run")
    );

    $compilation->create;
    $compilation->createDB($db);

    foreach my $service (keys %{$db->entities->{compilation_info}->installed_services}){
        $compilation->createService($service);
    }

    my $path = $save_path . '/' . $project_name;

    `cd $path; puzzle up --only-build`;
}

sub generate{
    my ($self, $type, @args) = @_;

    if($type eq 'project'){

        my ($name, $path) = @args;

        if(!$name){

            $self->error("puzzle generate project NAME [path]");
        }

        PrefApp::Puzzle::Generator->new->projectStructure(@args);
    }
    elsif($type eq 'piece'){

        my ($box, $name) = @args;

        my $piece = PrefApp::Puzzle::Generator->new->template($type);

        if(!$box){
            print $piece;
        }
        else{
        
            if(!$name){
                $self->error("puzzle generate piece BOX PIECE_NAME");
            }
    
            my $path = $ENV{PUZZLE_SOURCE_PATH} . "/" . $box;

            unless(-d $path){
                $self->error("Box $box does not exist");
            }

            $path .= "/" .$name;

            $path .= ".yml" unless($path =~ /\.yml$/);

            open(F, ">", $path) || $self->error("I/O error in $path: $!");

            print F $piece;

            close F;
        }
    }
}

1;
