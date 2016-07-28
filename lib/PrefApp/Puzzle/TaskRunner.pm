package PrefApp::Puzzle::TaskRunner;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    service=>undef,

    dockerForService=>undef,


);

sub runTasks :Sig(self, PrefApp::Puzzle::PieceTasks){
    my ($self, $tasks) = @_;

    $self->info("Running ", $tasks->label, " for ", $self->service);

    foreach my $task (values %{$tasks->tasks}){
        $self->runTask($task);
    }
}

sub runTask :Sig(self, PrefApp::Puzzle::PieceTask){
    my ($self, $task) = @_;

    foreach my $t ($task->tasks_list){

        $self->dockerForService->run(

            $task->container,
            
            $t

        );
    }

}

1;
