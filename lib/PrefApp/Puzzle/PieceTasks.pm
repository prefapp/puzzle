package PrefApp::Puzzle::PieceTasks;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    referer=>undef,

    label=>undef,

    tasks=>{}
    
);

sub BUILD_ALIAS{
    join('_', $_[0]->referer, $_[0]->label, "tasks");
}

sub addTask :Sig(self, PrefApp::Puzzle::PieceTask){
    my ($self, $task) = @_;

    $self->tasks->{$task->container} = $task;
}

sub tasksForContainer:Sig(self, s){
    my ($self, $container) = @_;

    $self->tasks->{$container};
}

1;
