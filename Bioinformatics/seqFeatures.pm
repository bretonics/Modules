#!/usr/bin/env perl

use strict; use warnings; use diagnostics; use feature qw(say);
use Getopt::Long; use Pod::Usage;

use FindBin; use lib "$FindBin::RealBin/lib";

use MyIO;

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
my $outFile = "features.out";
my $FH = getFH(">", $outFile);
#-------------------------------------------------------------------------
# CALLS
getFeatures($inSeqObj, $FH);

#-------------------------------------------------------------------------
# SUBS
sub getFeatures {
    my ($seqObj, $FH) = @_;
    my (@gene, @inference, @locusTag, @product, @proteinID, @translation);
    my @tags = qw(gene inference locus_tag product protein_id translation);

    say $FH join("\t", @tags); #print file header
    for my $feat ($seqObj->next_seq->get_SeqFeatures) {
        my $primaryTag = $feat->primary_tag;
        if ($primaryTag eq 'CDS') {
            for my $tag (@tags) {
                $feat->has_tag($tag) ? print $FH $feat->get_tag_values($tag), "\t" : print $FH " \t" ;
            }
            print $FH "\n"; #new line for each CDS

            # say "\nPrimary tag: $primaryTag at ", $feat->start;
            # for my $tag ($feat->get_all_tags) {
            #     # print 'Tag: ', $tag, " --- ";
            #     for my $value ($feat->get_tag_values($tag)) {
            #         say 'Value: ', $value;
            #     }
            # }
        }
     }
}
