package PrefApp::Puzzle::LoaderAddenda;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Loader';

use PrefApp::Puzzle::Addenda;

use PrefApp::Puzzle::YAML;

sub ADDENDA_CLASS{
    "PrefApp::Puzzle::Addenda";
}

sub __load{
    my ($self, $addenda, %args) = @_;

    # first we load the file of the piece
    my $data = $self->__loadAddendaData($addenda);

    # we create the piece
    my $piece = $self->createEntity(

        $self->ADDENDA_CLASS,

        data=>$_[0]->__loadAddendaData($addenda),

        %args

    );

}

    sub __loadAddendaData{
        my ($self, $addenda) = @_;

        PrefApp::Puzzle::YAML::Load(

            $self->__slurp(
            
                $addenda
           ) 
        )
    }

1;
