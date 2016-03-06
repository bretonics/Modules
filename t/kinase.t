#!/usr/bin/env perl

use strict; use warnings; use diagnostics; use feature qw(say);

use IO::Detect qw(is_filehandle);
use Test::More tests => 27;
use Test::Exception; #need this to get dies_ok and lives_ok to work

use FindBin; use lib "$FindBin::RealBin";


my $fileInName = "kinases_map_test";
my $fileOutName = "test.txt";

#-------------------------------------------------------------------------
BEGIN { use_ok('BioIO::MyIO', qw(getFh)) }
BEGIN { use_ok('BioIO::MyIO', qw(makeOutputDir)) }
BEGIN { use_ok('BioIO::Config') }
BEGIN { use_ok('BioIO::Kinases') }


dies_ok { my $kinaseObj = BioIO::Kinases->new() } 'dies ok when no argument is passed';
dies_ok { my $kinaseObj = BioIO::Kinases->new($fileInName, "2") } 'dies ok when >1 arguments are passed';
lives_ok { my $kinaseObj = BioIO::Kinases->new($fileInName) } 'lives ok when file is passed';
my $kinaseObj = BioIO::Kinases->new($fileInName);

dies_ok { BioIO::Kinases::_readKinases() } 'dies ok when no argument is passed';
dies_ok { BioIO::Kinases::_readKinases($fileInName, "2") } 'dies ok when >1 arguments are passed';
lives_ok { BioIO::Kinases::_readKinases($fileInName) } 'lives ok when file is passed';

dies_ok { $kinaseObj->printKinases($fileOutName); } 'dies ok when <3 arguments are passed';
dies_ok { $kinaseObj->printKinases($fileOutName, ['symbol','name','location'], "4" ); } 'dies ok when >3 arguments are passed';
lives_ok { $kinaseObj->printKinases($fileOutName, ['symbol','name','location'] ); } 'lives ok when correct # arguments are passed';

dies_ok { $kinaseObj->filterKinases() } 'dies ok when no argument is passed';
dies_ok { $kinaseObj->filterKinases( { name=>'tyrosine' }, "2" ) } 'dies ok when >2 arguments are passed';
lives_ok { $kinaseObj->filterKinases( {} ) } 'lives_ok ok when no filters passed'; #returns copy of object
lives_ok { $kinaseObj->filterKinases( { name=>'tyrosine' } ) } 'lives ok when hash is passed';
lives_ok { $kinaseObj->filterKinases( { name=>'tyrosine', symbol=>'EPLG4' } ) } 'lives ok when hash is passed with 2 filters';
lives_ok { $kinaseObj->filterKinases( { name=>'asdfe212' } ) } 'lives ok when hash is passed';

dies_ok { $kinaseObj->getAoh("2") } 'dies ok when >1 arguments are passed';
lives_ok { $kinaseObj->getAoh() } 'lives ok when no argument is passed';

dies_ok { $kinaseObj->getNumberOfKinases("2") } 'dies ok when >1 arguments are passed';
lives_ok { $kinaseObj->getNumberOfKinases() } 'lives ok when no argument is passed';

dies_ok { $kinaseObj->getElementInArray() } 'dies ok when <1 arguments are passed';
dies_ok { $kinaseObj->getElementInArray("1", "2") } 'dies ok when >1 arguments are passed';
lives_ok { $kinaseObj->getElementInArray('25') } 'lives ok when index passed exists';
lives_ok { $kinaseObj->getElementInArray('250') } 'lives ok when index passed does not exists'; #return only

# Clean Up
`rm OUTPUT/$fileOutName`;
