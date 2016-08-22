package PrefApp::Puzzle::EnvCompilation;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Entity';

use Storable qw(thaw);

has(
    env=>undef,
);

sub FREEZE_KEYS{
    qw(env)
}

sub initialize{
    my ($self, @args) = @_;

    $self->SUPER::initialize(@args);

    $self->env(\%ENV);
}

sub BUILD_ALIAS{
    "env"
}

sub get{
    $_[0]->env->{$_[1]};
}

sub STORABLE_thaw{
    my ($self, $cloning, $serialized) = @_;

    $serialized = thaw $serialized;

    $self->env(
        { %{$serialized->{env} || {}}, %ENV }
    );
}
1;
