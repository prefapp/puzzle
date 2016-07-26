use strict;
use Test::More;

use_ok("PrefApp::Puzzle::Base");

use_ok("PrefApp::Puzzle::Entity");
use_ok("PrefApp::Puzzle::Piece");
use_ok("PrefApp::Puzzle::Compose");
use_ok("PrefApp::Puzzle::ComposeConstruction");

use_ok("PrefApp::Puzzle::Environment");


use_ok("PrefApp::Puzzle::Vault");
use_ok("PrefApp::Puzzle::Data");

use_ok("PrefApp::Puzzle::Compilation");

use_ok("PrefApp::Puzzle::Loader");
use_ok("PrefApp::Puzzle::LoaderPiece");
use_ok("PrefApp::Puzzle::LoaderCompose");
use_ok("PrefApp::Puzzle::LoaderComposeConstruction");

use_ok("PrefApp::Puzzle::AttributeFinder");

use_ok("PrefApp::Puzzle::Commands");

done_testing;
