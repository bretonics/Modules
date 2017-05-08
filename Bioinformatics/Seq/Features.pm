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

=head1 NAME

Features - package to deal with sequence file features.

=head1 SYNOPSIS

use Bioinformatics::Seq::Features;

=head1 DESCRIPTION

This module was designed to save or print Genbank file features for each CDS to a file or stdout.

=head1 EXPORTS

=head2 Default Behaviors

use Bioinformatics::Seq::Features;

=head1 METHODS

=head2 getFeatures

  Arg [1]     :

  Example     :

  Description : Gets features provided a sequence fileS

  Returntype  :

  Status      : Stable

=cut
sub getFeatures {
  my ($files, $task) = @_;
  my @files = @$files;
  for my $file (@files) {
    my $inSeq   = Bio::SeqIO->new( -format => 'genbank' , -file => $file );
    my $seqObj  = $inSeq->next_seq;
    lookUpFeatures($seqObj, $task);
  }
}

=head2 lookUpFeatures

  Arg [1]     :

  Example     :

  Description : Looks up features provided a sequence object(s)

  Returntype  :

  Status      : Stable

=cut
sub lookUpFeatures {
  my ($seqObjects, $task) = @_;
  my @seqObjects  = @$seqObjects;
  my $numObjs     = @seqObjects;
  my @features;

  for(my $i=0; $i < $numObjs; $i++) {  # loop through seqObjects passed

    _saveFeatures($seqObjects[$i]) and next if($task eq 'save');

    for my $feat ($seqObjects[$i]->get_SeqFeatures) { # gets seqObject features
      # Get Coding Sequence (CDS)
      if ($feat->primary_tag eq 'CDS') {
        if ($task eq 'print') {
          _deliverFeatures($feat, $task);
        } else {
          # DEFAULT - Return data structure with all features
          push @features, _deliverFeatures($feat, $task);
        }
      }
    }
  }
}


# Save features to file
sub _saveFeatures {
  my ($seqObj) = @_;
  my @tags      = qw(gene locus_tag inference start end product protein_id translation);
  my $strain    = $seqObj->display_id;
  my $seq       = $seqObj->seq;
  my $molecule  = $seqObj->molecule;
  my $outFile   = 'features_' . $strain . '.txt';
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
      # Handle translation if not protein file
      my $translation = _translate() if($molecule eq 'PRT');
      print $FH $translation;
      print $FH "\n"; # new line for each CDS
    }
  }
}

# Deliver features as data structure or print to STDOUT
sub _deliverFeatures {
  my ($feat, $task) = @_;
  my (@data, %tags);

  say "\nPrimary Tag: ", $feat->primary_tag, " start: ", $feat->start, " ends: ", $feat->end, " strand: ", $feat->strand if($task);

  for my $tag ($feat->get_all_tags) { # gets seqObject tags from primary feature
    say "\ttag: $tag" if($task);
    for my $value ( $feat->get_tag_values($tag) ) { # gets seq object values from tag
      say "\tvalue: $value" and next if($task);
      push @data, $tags{$tag} = $value;
    }
  }
  return ( { 'start' => $feat->start, 'end' => $feat->end,
            'strand' => $feat->strand, 'tags' => \@data }
        );
}

sub _translate {
  my ($seq) = @_;
  return($seq->translate($seq));
}


=head1 COPYRIGHT AND LICENSE

Andres Breton (C) 2017

[LICENSE]

=head1 CONTACT

Please email comments or questions to Andres Breton, dev@andresbreton.com

=head1 SETTING PATH

If PERL5LIB was not set, do something like this:

use FindBin; use lib "$FindBin::RealBin";

This finds and uses current directoy as library location

=cut

1;
