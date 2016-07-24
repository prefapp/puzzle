package PrefApp::Puzzle::LoaderPiece;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Loader';

use PrefApp::Puzzle::Piece;

use YAML qw(Load);

sub PIECE_CLASS{
    "PrefApp::Puzzle::Piece";
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

1;
