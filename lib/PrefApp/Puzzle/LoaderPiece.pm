package PrefApp::Puzzle::LoaderPiece;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Loader';

use PrefApp::Puzzle::Piece;
use PrefApp::Puzzle::PieceEvent;

use YAML qw(Load);

sub PIECE_CLASS{
    "PrefApp::Puzzle::Piece";
}

sub PIECE_EVENT_CLASS{
    "PrefApp::Puzzle::PieceEvent"
}

sub __load{
    my ($self, $service, %args) = @_;

    # first we load the file of the piece
    my $data = $self->__loadPieceData($service, $args{box});

    # we create the piece
    my $piece = $self->createEntity(

        $self->PIECE_CLASS,

        service=>$service,

        data=>$data,

        %args

    );

    # load the base compose
    $piece->compose(
        $self->__loadCompose($piece)
    );

    # load the tasks for this piece
    $piece->tasks(

        $self->__loadTasks($piece)

    );

    # load the events for this piece
    $piece->events(

        $self->__loadEvents($piece)

    );

    return $piece;
}

    sub __loadPieceData{
        my ($self, $service, $box) = @_;

        Load(

            $self->__slurp(

                join(

                    "/",

                    $_[0]->basePath,

                    $box,

                    $service . '.yml',


                )
           ) 
        )
    }

    sub __loadCompose{
        my ($self, $piece) = @_;

        $self->loader(

            $self->LOADER_COMPOSE_CLASS
    
        )->load(

            $piece->service,

            $piece->origin,

            referer=>$piece->alias

        )
    }

    sub __loadTasks{
        my ($self, $piece) = @_;

        my $tasks = $piece->data->{tasks} || {};

        return {
        
            map {

                $_=> $self->loader(

                    $self->LOADER_PIECE_TASKS_CLASS
                
                )->load(

                    $_,

                    $tasks->{$_},

                    referer=>$piece->alias
                )

            } keys(%$tasks)

        }

    }

    sub __loadEvents{
        my ($self, $piece) = @_;

        my $events = $piece->data->{events} || {};

        return {

            map {

                $_ => $self->createEntity(

                    $self->PIECE_EVENT_CLASS,

                    referer=>$piece->alias,

                    name=>$_,

                    tasks=>$events->{$_}

                )

            } keys(%$events)

        };
    }

1;
