#!/usr/bin/perl

use strict; use warnings; use diagnostics; use feature qw(say);

use IO::Detect qw(is_filehandle);
use Test::More tests => 3;
use Test::Exception; #need this to get dies_ok and lives_ok to work

use FindBin; use lib "$FindBin::RealBin";


BEGIN { use_ok('MyConfig', qw(wrongNumberArguments)) }
dies_ok { wrongNumberArguments(1) } 'dies ok when an argument is passed';
lives_ok { wrongNumberArguments() } 'lives ok when no argument is passed';
