package Seq;

use diagnostics; use feature qw(say);
use Carp;

use FindBin; use lib "$FindBin::RealBin";

use Moose; use MooseX::StrictConstructor;

use MyIO; use Config;


# =============================================================================
#
#   CAPITAN: Andres Breton
#   FILE: Seq.pm
#   USAGE:
#
# =============================================================================

#-------------------------------------------------------------------------
# ATTRIBUTES
has "gi" => (is => "rw", isa => "Int",
             required => 1);
has "seq" => (is => "rw", isa => "Str",
              required => 1);
has "def" => (is => "rw", isa => "Str",
              required => 1);
has "accn" => (is => "rw", isa => "Str",
               required => 1);

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ($fileNameOut, $width);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This method writes the seq object to fasta file, where
# $fileNameOut is the outfile and $width is the width of the
# sequence column (default 70 if none provided)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub writeFasta {
    my $filledUsage = 'Usage: $seqObj->writeFasta($fileNameOut);';
    @_ == 2 || @_ == 3 or croak wrongNumberArguments(), $filledUsage;

    my ($self, $fileNameOut, $width) = @_;
    my $FH = getFh(">", $fileNameOut);
    $width = 70 unless ($width); #set default column width
    say "Writing file $fileNameOut...";
    say $FH ">gi|", $self->gi, "|ref|", $self->accn, "| ", $self->def; #print FASTA file header
    my $seqLen = length($self->seq);
    for (my $start = 0; $start < $seqLen;) { #print FASTA sequence with column $width
        my $row = substr $self->seq, $start, $width;
        say $FH $row;
        $start = $start+$width;
    }
}
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = $seqObj->subSeq($transSTART, $transEND);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This method receives the beginning and the ending translation
# sites, and returns a new Seq object between the sites
# (inclusive, sites are bio-friendly num)#
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = ($self); # new Seq object
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub subSeq {
    my $filledUsage = 'Usage: my $newSeqObj = $seqObj->subSeq($transSTART, $transEND);';
    @_ == 3 or croak wrongNumberArguments(), $filledUsage;

    my ($self, $start, $end) = @_;
    unless ($start and $end) {
        croak "Start and/or end sites were not defined", $!;
    }
    if ($end > length($self->seq)) { #not go outside length of sequence
        croak "Out of bounds 'end' passed. Sequence length is smaller than $end";
    }
    my $transLen = ($end-$start)+1;
    my $codingRegion = substr $self->seq, $start-1, $transLen; #get substring sequence
    $self->seq($codingRegion); #modify object with new substring sequence
    return $self; #return new Seq object
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = $seqObj->checkCoding();
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This method checks if a sequence starts with an ATG codon,
# and ends with a stop codon (i.e. TAA, TAG, or TGA)#
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = BOOLEAN
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub checkCoding {
    my $filledUsage = 'Usage: $seqObj->checkCoding();';
    @_ == 1 or croak wrongNumberArguments(), $filledUsage;

    my ($self) = @_;
    $self->seq =~ /^ATG\w+(TAA|TAG|TGA)$/ ? return 1: return;
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = $seqObj->checkCutSite( 'GGATCC' );
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This method receives a cut site pattern, sarches the sequence
# and determines the location of the cutting site. Returns the
# position and the sequence matched
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = ($pos, $seqFound);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub checkCutSite {
    my $filledUsage = 'Usage: $seqObj->checkCoding();';
    @_ == 2 or croak wrongNumberArguments(), $filledUsage;

    my ($self, $site) = @_;
    my ($pos, $sequence);
    if ( $self->seq =~ /$site/ ) {
        $sequence = $&;
        my $index = index($self->seq, $sequence);
        $pos = $index + 1; #correct index to make "friendly" number, i.e. not starting from 0
        return ($pos, $sequence);
    }
    return;
}
1;
