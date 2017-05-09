package ComposerMock;

use strict;
use Eixo::Base::Clase;

has(

    compose_data=>undef,

);


package Main;

use strict;
use Test::More;

use YAML::Syck qw(Load);
use Data::Dumper;

use Clone qw(clone);

use_ok("PrefApp::Puzzle::merger::ComposerMergerV2");
use_ok("PrefApp::Puzzle::merger::ComposeMerger");

my $c = Load join("", <DATA>);

my $m = PrefApp::Puzzle::merger::ComposerMergerV2->new(

    composer=>ComposerMock->new(

        compose_data=>$c,

    ),
    
    __composeData => clone($c),
);

$m->__createReferences("test");

ok($m->__refs->{ffmpeg_tool} eq 'test_ffmpeg_tool', "Reference has been created properly");

$m->__resolveReferences;

ok($m->__composeData->{services}->{test_tools}->{links}->[0] eq 'test_mongo:mongo', "Links properly resolved");

ok($m->__composeData->{services}->{test_tools_panel}->{volumes}->[1] eq 'test_pasarela:/home/panel', "Volumes properly resolved");

my $cm = PrefApp::Puzzle::merger::ComposeMerger->new;

$cm->addMergedPart($m->__composeData);

my $final = $cm->write;

ok($final, "We have a dumped version of the merged compose");

$final = Load($final);

ok($final->{version} eq "2", "Version is ok");

ok($final->{services}->{test_tools} && $final->{services}->{test_ffmpeg}, "Services seem ok");

ok((keys %{$final->{networks}}) == 0, "There is no networks");

ok($final->{volumes}->{test_tolemias_tools}, "Volumes seem ok");


done_testing;

__DATA__

version: "2"

services:

  tools_panel:

    image: node

    command: 'node app.js'

    working_dir: /home/tolemias

    volumes:
      - 'tolemias_panel:/home/tolemias'
      - 'pasarela:/home/panel'

    ports:
      - "3000:3000"
    environment:
      PUERTO_TOOLS: 7000
      HOST_TOOLS: 'http://172.17.0.1'
      PASARELA_ENTRADA: "/home/panel/entrada"
      PASARELA_SALIDA: "/home/panel/salida"

  tools: &api
    image: registry.prefapp.in:5000/prefapp/gpac
    working_dir: /home/tolemias
    command: plackup bin/start_api.psgi
    volumes:
      - 'tolemias_tools:/home/tolemias'
      - 'tolemias_dev:/home/prefapp'
      - 'ffmpeg_tool:/usr/local/ffmpeg'
      - 'pasarela:/tmp/pasarela'
    environment:
      FFMPEG_LIB_PATH: /usr/local/ffmpeg/lib
      PERL5LIB: /home/prefapp/catro-eixos/lib:/home/prefapp/eixo-utils/lib
      FFMPEG_BIN: /usr/local/ffmpeg/bin/ffmpeg
      DATOS_MONGO__HOST: mongo
      PASARELA_ENTRADA: /tmp/pasarela/entrada
      PASARELA_SALIDA: /tmp/pasarela/salida

    ports:
      - 7000:5000 
     
    links:
      - "mongo:mongo"
  
  tools_minions:
    <<: *api
    command: tarea start_minions foreground=1
    ports: []        

  tools_aux:
    <<: *api   
    command: '/bin/bash'
    ports: []

  mongo:
    restart: always
    image: registry.prefapp.in:5000/prefapp/mongo
    command: /root/start.sh
    volumes:
      - /var/lib/mongodb
  
  ffmpeg: 
    image: jrottenberg/ffmpeg
    entrypoint: /bin/true
    volumes:
      - 'ffmpeg_tool:/usr/local/'
    

volumes:
  tolemias_tools:
    driver_opts:
      type: none
      device: /home/tolemias/tolemias_tools
      o: bind
  tolemias_dev:
    driver_opts:
      type: none
      device: /home/prefapp
      o: bind
  tolemias_panel:
    driver_opts:
      type: none
      device: /home/tolemias/tolemias_tools/panel
      o: bind
  ffmpeg_tool:

  pasarela:
    driver_opts:  
      type: none
      device: ${RUTA_PASARELA}
      o: bind  

