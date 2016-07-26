use strict;
use Getopt::Long;

use PrefApp::Puzzle::Main;

my ($command, @args) = @ARGV;


PrefApp::Puzzle::Main->new(

    argv=>\@ARGV

)->run($command, @args);
