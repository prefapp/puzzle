package PrefApp::Puzzle::ComposeV2;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Compose';

has(

    artifacts=>{}
);

sub FREEZE_KEYS{

    $_[0]->SUPER::FREEZE_KEYS,

    qw(
        artifacts
    )
}

1;
