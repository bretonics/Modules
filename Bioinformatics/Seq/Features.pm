package Bioinformatics::Seq::Features;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(getFeatures lookUpFeatures);

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
#   USAGE:          Save/Print Genbank file features for each CDS to file/stdout
#   DEPENDENCIES:   - BioPerl modules
#                   - Own Modules repo
#
# =============================================================================


# Gets features provided a sequence file
sub getFeatures {
  my (@files) = @_;
  for my $file (@files) {
    my $inSeq   = Bio::SeqIO->new( -format => 'genbank' , -file => $file );
    my $seqObj  = $inSeq->next_seq;
    _saveFeatures($seqObj)
  }
}


# Gets features provided a sequence object
sub lookUpFeatures {
  my ($seqObjects, $task) = @_;
  my @seqObjects  = @$seqObjects;
  my $numObjs = @seqObjects;

  for(my $i=0; $i < $numObjs; $i++) {  # loop through seqObjects passed

    _saveFeatures($seqObjects[$i]) and next if($task eq 'save');

    for my $feat ($seqObjects[$i]->get_SeqFeatures) { # gets seqObject features
      # Get Coding Sequence (CDS)
      if ($feat->primary_tag eq 'CDS') {
        if ($task eq 'print') {
          _printFeatures($feat);
        } else {
          # TODO:intended to return a data structure with all features
          return;
        }
      }
    }
  }
}


# Save features to file
sub _saveFeatures {
  my ($seqObj) = @_;
  my @tags = qw(gene inference start end product protein_id translation);
  my $strain  = $seqObj->display_id;
  my $outFile = 'features_' . $strain . '.txt';
  # $file =~ /(.+\/)?(.+)\..+/;
  my $FH      = getFH('>', $outFile);

  say $FH join("\t", 'strain', 'strand', @tags); # print file header

  for my $feat ($seqObj->get_SeqFeatures) {
    my $primaryTag = $feat->primary_tag;

    if ($primaryTag eq 'CDS') {
      my $strand = $feat->strand;
      $strand == 1 ? $strand = '+' : $strand = '-';
      print $FH "$strain\t$strand\t";

      for my $tag (@tags) {
        if ($tag eq 'start') {
          print $FH $feat->start, "\t";
        } elsif ($tag eq 'end') {
          print $FH $feat->end, "\t";
        } else {
          $feat->has_tag($tag) ? print $FH $feat->get_tag_values($tag), "\t" : print $FH " \t" ;
        }
      }
      print $FH "\n"; # new line for each CDS
    }
  }
}


# Print features to STDOUT
sub _printFeatures {
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
