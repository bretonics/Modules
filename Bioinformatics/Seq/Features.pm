package seqFeatures;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(parseHeader parseFeatures); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;

use Bio::SeqIO; use Bio::SeqFeatureI;

# Own Modules (https://github.com/bretonics/Modules)
use MyIO;

# =============================================================================
#
#   CAPITAN:        Andres Breton, http://andresbreton.com
#   FILE:           seqFeatures.pm
#   LICENSE:        
#   USAGE:          Print Genbank file features for each CDS to file
#   DEPENDENCIES:   - BioPerl modules
#                   - Own Modules repo
#
# =============================================================================


sub lookUpFeatures {
    my (@seqObjects) = @_;
    my $arraySize = @seqObjects;
    for(my $i=0; $i<$arraySize;$i++) {  #loop through seqObjects passed
        for my $feat ($seqObjects[$i]->get_SeqFeatures) {   #gets seqObject features
            # Get Protein ID and Translation
            if ($feat->primary_tag eq "CDS") {
                getFeatures($feat, $feat->primary_tag);
            }
            # Get Exon
            if ($feat->primary_tag eq "exon") {
                getFeatures($feat, $feat->primary_tag);
            }
            }

        }
    }
}


sub getFeatures {
    my ($feat, $primaryTag) = @_;
    print "\nPrimary Tag: ", $feat->primary_tag, " start: ", $feat->start, " ends: ", $feat->end, " strand: ", $feat->strand,"\n";
    for my $tag ($feat->get_all_tags) { #gets seqObject tags from primary feature
        print " tag: ", $tag, "\n";
        for my $value ($feat->get_tag_values($tag)) { #gets seq object values from tag
            print "  value: ", $value, "\n";
        }
    }

}

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

=head1 COPYRIGHT AND LICENSE

Andres Breton (C) 2016

[LICENSE]

=head1 CONTACT

Please email comments or questions to Andres Breton, me@andresbreton.com

=head1 SETTING PATH

If PERL5LIB was not set, do something like this:

use FindBin; use lib "$FindBin::RealBin/lib";

This finds and uses subdirectory 'lib' in current directoy as library location

=cut

1;
