package PrefApp::Puzzle::LoaderPieceTasks;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Loader';

use PrefApp::Puzzle::PieceTasks;
use PrefApp::Puzzle::PieceTask;

sub PIECE_TASKS_CLASS{
    "PrefApp::Puzzle::PieceTasks";
}

sub PIECE_TASK_CLASS{
    "PrefApp::Puzzle::PieceTask";
}


sub __load{
    my ($self, $label, $data, %args) = @_;

    my $tasks = $self->createEntity(

        $self->PIECE_TASKS_CLASS,

        referer=>$args{referer},

        label=>$label,

    );

    $tasks->addTask($_) foreach($self->__loadTasks($data));

    $tasks;
}

sub __loadTasks{
    my ($self, $data) = @_;

    $self->fatal(
        "Tasks must be a MAP"
    ) unless(ref($data) eq 'HASH');

    my @tasks = map {

        $self->PIECE_TASK_CLASS->new(

            container=>$_,

            tasks_list=> $data->{$_}

        )

    } keys(%$data);

    wantarray ? @tasks : \@tasks
}   


1;
