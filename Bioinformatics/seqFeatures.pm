#!/usr/bin/env perl

use strict; use warnings; use diagnostics; use feature qw(say);
use Getopt::Long; use Pod::Usage;

use FindBin; use lib "$FindBin::RealBin/lib";

use MyIO;

use Bio::SeqIO; use Bio::SeqFeatureI;

# =============================================================================
#
#   CAPITAN: Andres Breton
#   FILE: seqFeatures.pl
#   LICENSE:
#   USAGE: Print Genbank file features for each CDS to file
#   DEPENDENCIES: BioPerl modules
#
# =============================================================================


#-------------------------------------------------------------------------
# COMMAND LINE
my @FILES;
my $usage= "\n\n$0 [options]\n
Options:
    -f      File
    -help   Shows this message

";
# OPTIONS
GetOptions(
    'f=s{1,}'   =>\@FILES,
    help    =>sub{pod2usage($usage);}
)or pod2usage(2);
# CHECKS
unless (@FILES){
    die "Did not provide an input file(s), -f <infile.txt>", $usage;
}
#-------------------------------------------------------------------------
# VARIABLES

#-------------------------------------------------------------------------
# CALLS
getFeatures(@FILES);

#-------------------------------------------------------------------------
# SUBS
sub getFeatures {
    my (@files) = @_;
    # my (@gene, @inference, @locusTag, @product, @proteinID, @translation);
    my @tags = qw(gene inference locus_tag product protein_id translation);


    for my $file (@files) {
        my $inSeqObj = Bio::SeqIO->new('-format' => 'genbank' , -file => $file);
        $file =~ /(.+\/)?(.+)\..+/; my $outFile = $2 . ".features";
        my $FH = getFH(">", $outFile);
        say $FH join("\t", @tags); #print file header

        for my $feat ($inSeqObj->next_seq->get_SeqFeatures) {
            my $primaryTag = $feat->primary_tag;
            if ($primaryTag eq 'CDS') {
                for my $tag (@tags) {
                    $feat->has_tag($tag) ? print $FH $feat->get_tag_values($tag), "\t" : print $FH " \t" ;
                }
                print $FH "\n"; #new line for each CDS
            }
         }
     }
}

