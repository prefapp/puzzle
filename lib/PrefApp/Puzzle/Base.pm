package PrefApp::Puzzle::Base;

use strict;
use Carp;
use Eixo::Base::Clase;

sub fatal{
    croak(@_[1..$#_]);
}

1;
