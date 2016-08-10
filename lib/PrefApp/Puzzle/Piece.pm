package PrefApp::Puzzle::Piece;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    data=>{},

    compose=>undef,

    tasks=>undef,

    events=>{},
);

sub FREEZE_KEYS{
    $_[0]->SUPER::FREEZE_KEYS, 
    qw(
        data
        tasks
        events
        compose
    )
}

sub BUILD_ALIAS{
    $_[0]->service . '_piece' 
}

sub validateThaw{
    my ($self) = @_;

    unless($self->compose){
        $self->fatal($self->alias . ' has not compose information');
    }
}

sub getApplicationContainers{
    $_[0]->data->{application_containers} || [];
}

sub origin{
    $_[0]->data->{origin};
}

sub exports{
    $_[0]->data->{exports} || {};
}

sub related{
    $_[0]->data->{related} || {};
}

sub weight{
    $_[0]->data->{weight};
}

sub getTasksFor :Sig(self, s){ 
    my ($self, $label) = @_;

    $self->tasks->{$label};
}

sub eventFired:Sig(self, s){
    my ($self, $event) = @_;

    return () unless($self->events->{$event});

    my $tasks = $self->events->{$event}->tasks;

    $tasks = [$tasks] unless(ref($tasks) eq 'ARRAY');

    return map {

        $self->getTasksFor($_)

    } @$tasks
}


1;
