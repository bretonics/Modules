package Features;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(getFeatures printFeatures); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;

use Bio::SeqIO; use Bio::SeqFeatureI;

# Own Modules (https://github.com/bretonics/Modules)
use MyIO;

# =============================================================================
#
#   CAPITAN:        Andres Breton, http://andresbreton.com
#   FILE:           Features.pm
#   LICENSE:
#   USAGE:          Print Genbank file features for each CDS to file
#   DEPENDENCIES:   - BioPerl modules
#                   - Own Modules repo
#
# =============================================================================


sub getFeatures {
  my (@seqObjects) = @_;
  my $numObjs = @seqObjects;
  for(my $i=0; $i < $numObjs; $i++) {  # loop through seqObjects passed
    for my $feat ($seqObjects[$i]->get_SeqFeatures) { # gets seqObject features
      # Get Protein ID and Translation
      if ($feat->primary_tag eq 'CDS') {
        _printFeatures($feat);
      }
      # Get Exon
      if ($feat->primary_tag eq 'exon') {
        _printFeatures($feat);
      }
    }
  }
}


sub printFeatures {
  my (@files) = @_;
  my @tags = qw(gene inference start end product protein_id translation);

  for my $file (@files) {
    my $inSeq   = Bio::SeqIO->new( -format => 'genbank' , -file => $file );
    my $seqObj  = $inSeq->next_seq;
    my $strain  = $seqObj->display_id;

    $file =~ /(.+\/)?(.+)\..+/;
    my $outFile = $2 . '.features';
    my $FH      = getFH('>', $outFile);

    say $FH join("\t", 'strain', 'strand', @tags); # print file header

    for my $feat ($seqObj->get_SeqFeatures) {
      my $primaryTag = $feat->primary_tag;

      if ($primaryTag eq 'CDS') {
        my $strand = $feat->strand();
        if ($strand == 1) {
          $strand = '+';
        } else {
          $strand = '-';
        }
        print $FH "$strain\t$strand\t";

        for my $tag (@tags) {
          if ($tag eq 'start') {
            print $FH $feat->start(), "\t";
          } elsif ($tag eq 'end') {
            print $FH $feat->end(), "\t";
          } else {
            $feat->has_tag($tag) ? print $FH $feat->get_tag_values($tag), "\t" : print $FH " \t" ;
          }
        }
        print $FH "\n"; # new line for each CDS
      }
    }
  }
}


sub _lookUpFeatures {
  my ($feat) = @_;
  say "\nPrimary Tag: ", $feat->primary_tag, " start: ", $feat->start, " ends: ", $feat->end, " strand: ", $feat->strand;

  for my $tag ($feat->get_all_tags) { # gets seqObject tags from primary feature
    say "\ttag: $tag";
    for my $value ( $feat->get_tag_values($tag) ) { # gets seq object values from tag
      say "\tvalue: $value";
    }
  }
}

=head1 COPYRIGHT AND LICENSE

Andres Breton (C)

[LICENSE]

=head1 CONTACT

Please email comments or questions to Andres Breton, <dev@andresbreton.com>

=head1 SETTING PATH

If PERL5LIB was not set, do something like this:

use FindBin; use lib "$FindBin::RealBin/lib";

This finds and uses subdirectory 'lib' in current directory as library location

=cut

1;
