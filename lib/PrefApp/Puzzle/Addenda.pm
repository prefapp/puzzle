package PrefApp::Puzzle::Addenda;


use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

has(

    name=>undef,

    data=>undef,

);

sub FREEZE_KEYS{
    $_[0]->SUPER::FREEZE_KEYS,
    qw(
        name
        data
    )
}

sub BUILD_ALIAS{
    "addenda"
}

sub exports{
    $_[0]->data->{exports};
}

1;
