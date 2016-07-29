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

  - **PUZZLE_SOURCE_PATH**
  - **PUZZLE_BOX**
  - **PUZZLE_COMPILATION_PATH**

##Puzzle - Pieces

Small composable units that define a service and its relations with others

```yaml

# base service
origin: foo/docker-compose.yml 

application_containers: [container_1, container_2]

# basic environment configuration
exports:
  container_1:
    a: 1
    b: 2
  container_2:
    LOL: 1
    FOO: 1

# configuration options for other pieces
related:
    "container_3 + container_4": 
      c: 3
      d: 4 

```



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


##COPYRIGHT AND LICENCE

Copyright (C) 2016, Francisco Maseda

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

