use 5.018001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'PrefApp::Puzzle',
    VERSION_FROM      => 'lib/PrefApp/Puzzle.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {
        'Eixo::Base' => '1.500',
        'JSON::XS' => '3.02',
        'YAML::Syck' => '1.29',
        'List::MoreUtils' => '0.41',
        'Hash::Merge' => '0.20' ,
        'Getopt::Long' => '2.49'
    
    }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/PrefApp/Puzzle.pm', # retrieve abstract from module
    AUTHOR            => 'root <root@>',
    EXE_FILES           => ["bin/puzzle"],
    #LICENSE           => 'perl',
    #Value must be from legacy list of licenses here
    #http://search.cpan.org/perldoc?Module%3A%3ABuild%3A%3AAPI
);
