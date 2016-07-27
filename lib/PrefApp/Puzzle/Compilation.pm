package PrefApp::Puzzle::Compilation;

use strict;
use Eixo::Base::Clase 'PrefApp::Puzzle::Base';
use File::Path qw(make_path remove_tree);

use JSON::XS;

has(

    path=>undef,

    validServices=>[],

);

sub serviceInstalled{
    $_[0]->__isServiceInstalled($_[1])
}

sub serviceComposePath{
    my ($self, $service) = @_;

    unless($self->__isServiceInstalled($service)){

        $self->fatal(

            "Service $service is not installed"

        );

    }

    return (

        join(

            "/",

            $self->path,

            $service,

            "docker-compose.yml"

        )

    )
}

sub deleteService{
    my ($self, $service) = @_;

    unless($self->__isServiceInstalled($service)){

        $self->fatal(

            "Service $service is not installed, cannot be deleted"

        );
    }

    remove_tree(

        join(

            '/',

            $self->path,

            $service

        )
    ) || $self->fatal(

        "Service delete: error in remove_tree: " . $!

    );
}

sub getServiceCompilationArgs :Sig(self, s){
    my ($self, $service) = @_;

    JSON::XS->new->decode(

        $self->__getFile(

            join(

                "/",

                $self->path,

                $service,

                "args"

            )
        )
    );
}

sub getServices{
    return $_[0]->__loadServices;
}

sub create{
    my ($self) = @_;

    make_path($self->path) || $self->fatal(
        "Could not create compilation path: " . $!
    );
    
}

sub createService{
    my ($self, $service, %files) = @_;

    mkdir($self->path . '/' . $service) || $self->fatal(
        "Could not create service path: " . $!
    );

    foreach my $file (keys(%files)){

        my $path = join('/', $self->path, $service, $file);

        $self->createFileService(

            $path,

            $files{$file}
        );
    }
}

sub createFileService{
    my ($self, $path, $file) = @_;

    my $f;
    open ($f, '>', $path) || $self->fatal(
        "Could not create file service: $path: " . $!
    );

    print $f $file;

    close $f;
}


sub destroy{
    my ($self) = @_;

    remove_tree($self->path) || $self->fatal(
        "Could not remove compilation path: " . $!
    );
}

sub __loadServices{
    my ($self) = @_;

    my $d;

    opendir($d, $self->path) || $self->fatal(
        "Could not open compilation path: " . $!
    );

    my @services = grep {

        $self->__isValidService($_);

    } readdir($d);
    
    closedir $d;

    return @services;
}

sub __isValidService{
    grep {
        $_ eq $_[1]
    } @{$_[0]->validServices}
}

sub __isServiceInstalled{

    grep {
        $_ eq $_[1]
    } $_[0]->getServices

}


sub __getFile{

    open F, $_[1];
    my $d = join '', <F>;
    close F;

    return $d;
}

1;
