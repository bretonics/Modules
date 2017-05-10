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
#   USAGE:          Return, print to STDOUT, or save to file GenBank file features for each CDS
#   DEPENDENCIES:   - BioPerl modules
#                   - Own Modules repo
#
# =============================================================================

=head1 NAME

Features - package to deal with GenBank file sequence features.

=head1 SYNOPSIS

use Bioinformatics::Seq::Features;

=head1 DESCRIPTION

This module was designed to return, print to STDOUT, or save to a file sequence features for each CDS provided a GenBank file.

=head1 EXPORTS

=head2 Default Behaviors

use Bioinformatics::Seq::Features;

=head1 METHODS

=head2 getFeatures

  Arg [1]     : GenBank file(s)

  Arg [2]     : Default - No parameter passed.

                Optional - Task to perform by lookUpFeatures() after obtaining features: return (undef default), print to STDOUT, or save to file.

  Example     : getFeatures($file)

  Description : Gets features provided a sequence files.

  Returntype  : Default - Returns array of sequence features.

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

  Arg [1]     : Sequence object(s)

  Arg [2]     : Optional - Task to perform by lookUpFeatures() after obtaining features.
                Task 'task' will be executed: return (undef default), print to STDOUT, save to file.

  Example     : lookUpFeatures(\@seq);
                lookUpFeatures(\@seq, 'print');
                lookUpFeatures(\@seq, 'save');

  Description : Looks up all features provided a sequence object(s)

  Returntype  : Array:
                  Default - Returns array of sequence features.
                  Defined - Option to return (undef default), print to STDOUT, or save to file.

  Status      : Stable

=cut
sub lookUpFeatures {
  my ($seqObjects, $task) = @_;
  my @seqObjects  = @$seqObjects;
  my $numObjs     = @seqObjects;
  $task = 'return' unless $task; # deal with undef default value

  my (@features, %data);

  for(my $i=0; $i < $numObjs; $i++) {  # loop through seqObjects passed

    _saveFeatures($seqObjects[$i]) and next if($task eq 'save');

    for my $feat ($seqObjects[$i]->get_SeqFeatures) { # gets seqObject features
      # Get Coding Sequence (CDS)
      if ($feat->primary_tag eq 'CDS') {
        if ($task eq 'return') {
          # DEFAULT - Return data structure with all features for each CDS
          push @features, _deliverFeatures($feat);
        } elsif ($task eq 'print') {
          _deliverFeatures($feat, $task);
        } else {
          croak "Task '$task' is not supported. Use 'print' or 'save'.";
        }
      }
    }
    $data{$seqObjects[$i]->display_id} = \@features;
  }
  # Return HoAoH data structure of all features for all sequence objects passed
  return \%data;
}

#-------------------------------------------------------------------------------
# PRIVATE FUNCTIONS

# Save features to file
sub _saveFeatures {
  my ($seqObj)  = @_;
  my @tags      = qw(gene locus_tag inference start end product protein_id translation);
  my $strain    = $seqObj->display_id;
  my $molecule  = $seqObj->molecule;
  my $outFile   = 'features_' . $strain . '.txt'; # $file =~ /(.+\/)?(.+)\..+/;
  my $FH        = getFH('>', $outFile);

  say "Saving features for $strain...";
  say $FH join("\t", 'strain', 'strand', @tags); # print file header

  for my $feat ($seqObj->get_SeqFeatures) {
    my $primaryTag = $feat->primary_tag;

    if ($primaryTag eq 'CDS') {
      # my $seq     = $feat->seq->seq;
      my $strand  = $feat->strand;
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
      # print $FH translate($seq) if($molecule eq 'DNA');
      print $FH "\n"; # new line for each CDS
    }
  }
  say "Features file saved to '$outFile'";
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
