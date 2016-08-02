use strict;
use Test::More;

use_ok("PrefApp::Puzzle::YAML");

my $h = PrefApp::Puzzle::YAML::Load(join("\n", <DATA>));

ok(
    array_cmp(

        [sort(keys(%{$h->{promotor}}))],
        [sort(keys(%{$h->{promotor_sidekiq}}))]
    ),

    'Ambas construcciones tiene las mismas keys'
);

ok(
    $h->{promotor}->{command} eq 'cmd1' &&
    $h->{promotor_sidekiq}->{command} eq 'cmd2',

    'El merge se realiza correctamente'
);

ok(
    !exists($h->{promotor}->{nueva_key}) &&
        $h->{promotor2}->{nueva_key} eq 'yeah',

    "El merge de 2 permite agregar nuevas keys"
);

like(

    PrefApp::Puzzle::YAML::Dump($h),
    
    qr/promotor_sidekiq/,

    "Dump funciona correctamente"
);

done_testing();

sub array_cmp{

    my ($arr1, $arr2) = @_;

    for my $i (0..@$arr1-1){

        return undef unless($arr1->[$i] eq $arr2->[$i]);
    }

    return 1;
}



__DATA__
promotor: &app 
  restart: always
  image: registry.prefapp.in:5000/prefapp/promotor
  container_name: promotor
  external_links: 
    - redis:redis
  command: cmd1
  working_dir: /home

promotor_sidekiq: 
  <<: *app
  command: cmd2

promotor2:
  <<: *app
  nueva_key: yeah
