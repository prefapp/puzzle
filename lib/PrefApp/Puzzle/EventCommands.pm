package PrefApp::Puzzle::EventCommands;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

use PrefApp::Puzzle::TaskRunner;

has(

    opts=>undef,

    env=>undef,

    refDB=>undef,

    refVault=>undef,

    dockerCommands=>undef,
);

sub runTaskForService :Sig(self, s, s){
    my ($self, $task, $service) = @_;

    my $piece = $self->refVault->get($service . '_piece');

    if(my $task_object = $piece->getTasksFor($task)){
        
        $self->__runnerForService($service)->runTasks(

            $task_object

        );
    }
    else{
        $self->error("$service does not have a task labelled $task");
    }
}

sub fireEventForService :Sig(self, s, s){
    my ($self, $event, $service, $continue) = @_;

    my $runner = $self->__runnerForService($service);

    $self->info("Running tasks for event $event on service $service");

    my @event_tasks = $self->refVault

                    ->get($service . '_piece')

                            ->eventFired($event);
        
    $runner->runTasks($_, $continue) foreach(@event_tasks);
}


sub __runnerForService{
    my ($self, $service) = @_;

    my @extras;

    if(my $t_arg = $self->opts->{arg}){
        @extras = map { $_ . "=" . $t_arg->{$_}} keys(%$t_arg);
    }

    PrefApp::Puzzle::TaskRunner->new(

        service=>$service,

        dockerForService=>$self->__dockerForService(

            $service

        ),

        extra=>\@extras

    );
}

sub __dockerForService{
    my ($self, $service) = @_;

    $self->dockerCommands->__dockerForService($service);
}

1;
