puzzle
========

Puzzle is a tool to create environments with docker and docker-compose

##To start using it

```
Usage: puzzle COMMAND [arg...]

Commands:

    up      Launches one or more puzzle services
    down    Stops and deletes installed puzzle services
    ps      Information about installed puzzle services
    task    Runs a bunch of jobs in a service 
    
```

## Config

  - **PUZZLE_SOURCE_PATH**: Base path where puzzle can locate compose files and pieces to process
  - **PUZZLE_BOX**: folder inside PUZZLE_SOURCE_PATH where are defined the pieces of a environment
  - **PUZZLE_COMPILATION_PATH**: path where puzzle stores the final docker-compose files processed

##Puzzle - Pieces

Small composable units that define a service and its relations with others

```yaml

# base service
origin: foo/docker-compose.yml 

application_containers: [container_1, container_2]

# basic environment configuration
env:
  container_1:
    a: 1
    b: 2
  container_2:
    LOL: 1
    FOO: 1

# configuration options for other pieces
overrides:
    "container_3 + container_4": 
      c: 3
      d: 4 

tasks:
    install:
        arquitecto: 
            - task 1
            - task 2
            - task 3
        arquitecto_minions:
            - task 1
            - task 2
            - taks 3

```

## Addendas

Addendas allow the ability to reconfigure pieces from another config file (addenda). 
Override or complete params from one or several pieces but isn't a service representation.
Only has the **exports** section, where is detailed the parameters that wich wants reconfigure, of 1-N pieces.

Addendas are added at the end, so its configurations override any other.

To use an addenda when you are creating a new environment:  

``` puzzle up --add <path to addenda file relative to PUZZLE_SOURCE_PATH>```


##DEPENDENCIES

This module requires these other modules and libraries:

```perl

requires 'Eixo::Base', '>= 1.500, < 2';
requires 'JSON::XS', '>= 3.02, < 4';
requires 'YAML::Syck', '>= 1.29, < 1.3';
requires 'List::MoreUtils', '>=0.41, <= 0.5';
requires 'Hash::Merge', '>=0.20, <= 0.30';
requires 'Getopt::Long', '>=2.49, <= 3.0';
```

View cpanfile.

To install :

``` cpanfile --installdeps .```

* Needs **make** and **gcc**  
``` sudo apt-get install make gcc  libc6-dev```

##COPYRIGHT AND LICENCE

Copyright (C) 2016, Francisco Maseda

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

