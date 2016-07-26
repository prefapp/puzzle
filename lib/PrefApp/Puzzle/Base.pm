package PrefApp::Puzzle::Base;

use strict;
use Carp;
use Eixo::Base::Clase;

sub info{
    print @_[1..$#_], "\n";
}

sub fatal{
    croak(@_[1..$#_]);
}

sub error{
    print @_[1..$#_], "\n";
    exit 1;
}

1;
