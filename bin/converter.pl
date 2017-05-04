#!/usr/bin/env perl

use strict; use warnings; use diagnostics; use feature qw(say);
use Bio::SeqIO;

# =============================================================================
#
#   CAPITAN:        Andres Breton
#   FILE:           seqConverter.pl
#   USAGE:          Turn GenBank files into FASTA
#   DEPENDENCIES:   BioPerl
#
# =============================================================================

my $inFile    = $ARGV[0];
my ($outFile) = $inFile =~ /(.*)\.gbk?$/; $outFile = $outFile . '.fasta';

my $seqIn   = Bio::SeqIO->new( -file => $inFile, -format => 'genbank' );
my $seqOut  = Bio::SeqIO->new( -file => ">$outFile", -format => 'fasta' );

while ( my $seq = $seqIn->next_seq ) {
    $seqOut->write_seq($seq);
}
