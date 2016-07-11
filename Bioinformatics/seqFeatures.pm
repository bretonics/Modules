#!/usr/bin/env perl

use strict; use warnings; use diagnostics; use feature qw(say);
use Getopt::Long; use Pod::Usage;

use FindBin; use lib "$FindBin::RealBin/lib";

use Bio::SeqIO; use Bio::SeqFeatureI;

# =============================================================================
#
#   CAPITAN:
#   FILE:
#   LICENSE:
#   USAGE:
#   DEPENDENCIES:
#
# =============================================================================


#-------------------------------------------------------------------------
# COMMAND LINE
my $FILE;
my $usage= "\n\n$0 [options]\n
Options:
    -f      File
    -help   Shows this message

";
# OPTIONS
GetOptions(
    'f=s'   =>\$FILE,
    help    =>sub{pod2usage($usage);}
)or pod2usage(2);
# CHECKS
unless ($FILE){
    die "Did not provide an input file, -f <infile.txt>", $usage;
}
#-------------------------------------------------------------------------
# VARIABLES
my $inSeqObj = Bio::SeqIO->new('-format' => 'genbank' , -file => $FILE);

#-------------------------------------------------------------------------
# CALLS
getFeatures($inSeqObj);
