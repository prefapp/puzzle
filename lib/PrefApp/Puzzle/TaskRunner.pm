package PrefApp::Puzzle::TaskRunner;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';

has(

    service=>undef,

    dockerForService=>undef,


);

sub runTasks :Sig(self, PrefApp::Puzzle::PieceTasks){
    my ($self, $tasks, $continue) = @_;

    $self->info("Running ", $tasks->label, " for ", $self->service);

    foreach my $task (values %{$tasks->tasks}){
        $self->runTask($task, $continue);
    }
}

sub runTask :Sig(self, PrefApp::Puzzle::PieceTask){
    my ($self, $task, $continue) = @_;

    foreach my $t (@{$task->tasks_list}){

        eval{

            $self->dockerForService->run(

                $task->container,
            
                $t

            );

        };
        if($@){

            unless($continue){
                $self->fatal($@);
            }

            print $@;
        }
    }

}

1;
