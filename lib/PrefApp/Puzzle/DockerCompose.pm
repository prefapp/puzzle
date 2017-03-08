package PrefApp::Puzzle::DockerCompose;

use strict;
use Eixo::Base::Clase qw(PrefApp::Puzzle::Base);

use IPC::Open3;
use Symbol;

my $EN_MOCKUP = undef;
my $F_MOCKUP = undef;

sub SET_EN_MOCKUP{
    my ($self, $code) = @_;

    $EN_MOCKUP = 1;
    $F_MOCKUP = $code;
}

sub DOCKER_COMPOSE{
    '/usr/local/bin/docker-compose'   
}

sub DOCKER{
    "/usr/bin/docker"
}

has(

    en_mockup=>undef,

    path=>undef,

    env=>undef,
);

sub recargar{
    my ($self, @containers) = @_;

    $self->stop(@containers);

    $self->rm(@containers);

    $self->up(@containers);
}

sub rm{
    my ($self, @containers) = @_;

    $self->execSalida(

        $self->DOCKER_COMPOSE,

        "-f",

        $self->{ruta},

        "rm",

        "-f",

        @containers
    );
}

sub stop{
    my ($self, @containers) = @_;

    $self->execSalida(

        $self->DOCKER_COMPOSE,
    
        "-f",
    
        $self->{path},

        "stop",

        @containers

    );
}

sub start{
    my ($self, @containers) = @_;

    $self->execSalida(

        $self->DOCKER_COMPOSE,

        "-f",

        $self->{path},

        "start",

        @containers

    );

}

sub ps{
    my ($self) = @_;

    $self->execSalida(

        $self->DOCKER_COMPOSE,

        "-f",

        $self->{path},

        "ps",

    )
}   

sub up{
    my ($self, @containers) = @_;

    $self->execSalida(

        $self->DOCKER_COMPOSE,

        "-f",

        $self->{path},

        "up",

        "-d",

        @containers
    )
}

sub down{
    my ($self) = @_;
    
    $self->exec(

        $self->DOCKER_COMPOSE,

        "-f",

        $self->{path},

        "down",

        "-v"
    );
}

sub composePull{
    my ($self) = @_;

    $self->execSalida(

        $self->DOCKER_COMPOSE,

        "-f",

        $self->{path},

        "pull"

    );
}

sub pull{
    my ($self, $imagen) = @_;

    system(qq(docker pull $imagen));
}

sub run{
    my ($self, $container, $command) = @_;
    
    $self->execSalida(

        $self->DOCKER_COMPOSE,

        "-f",

        $self->{path},

        "run",

        "--rm",

        $container,

        $self->splitCommand($command)

    );
}

sub execSalida{
    &exec(@_);

    print $_[0]->{stdout}, "\n";
    print $_[0]->{stderr}, "\n";
}

sub exec{
    my ($self, @comando) = @_;

    $self->{status} = undef;
    $self->{stdout} = '';
    $self->{stderr} = '';

    use IO::File;

    local *MYOUT = IO::File->new_tmpfile;

    local *MYERR = IO::File->new_tmpfile;

    # set environment
    local %ENV = %{$self->{env} || {}};

    if($EN_MOCKUP){
           return $F_MOCKUP->($self, @comando); 
    }

    my $pid = open3(
            
            my $stdin = gensym(),

            ">&MYOUT",
            ">&MYERR",
     
            @comando       
    );

    waitpid($pid, 0);
    
    seek $_,0,0 for \*MYOUT, \*MYERR;

    my ($salida, $salida_error);

    {

        local $/ = undef;        
        $salida = <MYOUT>;       
        $salida_error = <MYERR>; 
    }

    $self->{stdout} = $salida;

    MYOUT->autoflush(1);
    MYERR->autoflush(1);

    chomp($self->{stdout});

    $self->{stderr} = $salida_error;

    if($? == -1){

        $self->{status} = -1;

        die('Error al ejecutar '.join(' ' , @comando));

    }
    elsif($? & 127){

        die('Comando '. join(' ',@comando) . ' finalizado inexperadamente con SIGNAL = '.($? & 127));
    }                                                                                                    
    else{

        my $estado = $?>>8;

        $self->{status} = $estado;

        if($estado != 0){                                                                       
       
            die('Error al ejecutar ['.join (' ', @comando)."] (status:".

                $self->{status}.'). Salida: '.

                $self->{stdout}."\nError:".$self->{stderr}

            ) 
        }

    }

    return $self;
}

sub splitCommand {
    my ($self, $cmd) = @_;

    my @cmd;
    # 
    # regexp que permite partir por espacios y por bloques entrecomillados
    #
    while($cmd =~ /((\"[^"]+\")|(\'[^']+\')|([^\s]+))\s?/g){
        my $token = $1;
        $token =~ s/(^["']|["']$)//g;
        push @cmd, $token;
    }

    @cmd;

}

1;
