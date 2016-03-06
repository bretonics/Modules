#!/usr/bin/env perl

use strict; use warnings; use diagnostics; use feature qw(say);

use IO::Detect qw(is_filehandle);
use Test::More tests => 23;
use Test::Exception; #need this to get dies_ok and lives_ok to work

use FindBin; use lib "$FindBin::RealBin";


BEGIN { use_ok('BioIO::MyIO', qw(getFh)) }
BEGIN { use_ok('BioIO::MyIO', qw(makeOutputDir)) }

# Create Files
my $goodFile = "goodNt_$$";
my $outFile1 = "outNt_$$";
my $outFile2 = "appendNt_$$";
my $nonExistent  = "non-existent.txt";
createFile($goodFile);

# File Handles
my $fhInGood     = getFh("<", $goodFile);
my $fhOutGood1   = getFh(">", $outFile1);
my $fhOutGood2   = getFh(">>", $outFile2);


# IO::Detect to test if file handles
is(is_filehandle $fhInGood,   1, "is_filehandle passed");
is(is_filehandle $fhOutGood2, 1, "is_filehandle passed");
is(is_filehandle $fhOutGood1, 1, "is_filehandle passed");

#dies when too many arguments are given
dies_ok { getFh("<", $fhInGood, 1) } 'dies ok when too many arguments are given';
#dies when not enough many arguments are given
dies_ok { getFh("<") } 'dies ok when not enough arguments are given';
#dies when not filename is given
dies_ok { getFh("<", "") } 'dies ok on no file';
#dies when a director is given
dies_ok { getFh("<", "/Users/breton/Dropbox/") } 'dies ok on a directory passed in';
dies_ok { getFh("<", "/home/breton.a/") } 'dies ok on a directory passed in';

#dies when give it a bogus file operation
dies_ok { getFh("<<", $fhInGood) } 'dies ok on <<';
#dies when no type of file to open is not given
dies_ok { getFh("", $fhInGood) } 'dies ok on no operation';

#dies when file is non-existent
dies_ok { getFh("<", $nonExistent) } 'dies ok reading !-e file';
dies_ok { createFile("") } 'dies ok createFile without file';
dies_ok { getFh(">", "") } 'dies ok on writing nonExistent file';
dies_ok { getFh(">>", "") } 'dies ok on appending nonExistent file';

#lives when reading and good filename is given
lives_ok { getFh("<", $goodFile) } 'lives ok on reading good file';
#lives when writing and good filename is given
lives_ok { getFh(">", $goodFile) } 'lives ok on writing good file';
#lives when appending and good filename is given
lives_ok { getFh(">>", $goodFile) } 'lives ok on appending good file';


# makeOutputDir
dies_ok { BioIO::MyIO::makeOutputDir() } 'makeOutputDir dies ok when not enough arguments are given';
dies_ok { BioIO::MyIO::makeOutputDir("TEST", "HELLO") } 'makeOutputDir dies ok when not > 1 arguments are given';
lives_ok { BioIO::MyIO::makeOutputDir("TEST") } 'makeOutputDir lives ok when directory does not exist';
lives_ok { BioIO::MyIO::makeOutputDir("TEST") } 'makeOutputDir lives ok when directory exists';

# Clean Up
unlink $goodFile;
unlink $outFile1;
unlink $outFile2;
`rm -r TEST`;

sub createFile{
    my ($file) = @_;
    my $fhIn1;
    unless (open ($fhIn1, ">" , $file) ){
        die $!;
    }
    print $fhIn1 <<'_FILE_';
test
_FILE_
    close $fhIn1;
    return;
}
