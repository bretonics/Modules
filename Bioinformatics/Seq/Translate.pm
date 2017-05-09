package Bioinformatics::Seq::Translate;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(translate);
our @EXPORT_OK = qw(getAA);

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;

# Own Modules (https://github.com/bretonics/Modules)
use MyIO;
use Bioinformatics::Seq;

# =============================================================================
#
#   CAPITAN:        Andres Breton, http://andresbreton.com
#   FILE:           Translate.pm
#   LICENSE:
#   USAGE:
#   DEPENDENCIES:   - Own Modules repo
#
# =============================================================================

=head1 NAME

Translate - package for DNA/RNA sequence translation.

=head1 SYNOPSIS

use Bioinformatics::Seq::Translate;

=head1 DESCRIPTION

This module was designed to translate DNA/RNA sequences into protein. It will print or return translated sequence in multiple formats, including full amino acid names or abbreviations.

=head1 EXPORTS

=head2 Default Behaviors

use Bioinformatics::Seq::Translate;

=head1 METHODS

=head2 translate

  Arg [1]     : DNA/RNA sequence

  Arg [2]     : Default - No parameter passed.

                Optional - Action to take with translated sequence.
                Action parameter passed determines action taken as 'task' with 'type' passed to getAA().

  Example     : translate('atggaaaagc');
                translate('atggaaaagc', 'print');
                NOTE: See getAA() for more options for action parameter.

  Description : Translates DNA/RNA sequence provided a DNA/RNA sequence.

  Returntype  : Array:
                  Default - Returns translated sequence.
                  Defined - Option to return, print, or save translation sequence.

  Status      : Stable

=cut
sub translate {      #Translate DNA/RNA to protein according to transTable designation
  my ($sequence, $action) = @_;
  my $seqLen = length $sequence;
  my @translation;

  my %transTable = (
    GCA  => 'A', GCC  => 'A', GCG  => 'A', GCT  => 'A', GCU  => 'A',
    AGA  => 'R', AGG  => 'R', CGA  => 'R', CGC  => 'R', CGG  => 'R',
    CGT  => 'R', CGU  => 'R', AAC  => 'N', AAT  => 'N', AAU  => 'N',
    GAC  => 'D', GAT  => 'D', GAU  => 'D', TGC  => 'C', UGC  => 'C',
    TGT  => 'C', UGU  => 'C', CAG  => 'Q', CAA  => 'Q', GAG  => 'E',
    GAA  => 'E', GGT  => 'G', GGU  => 'G', GGG  => 'G', GGC  => 'G',
    GGA  => 'G', CAT  => 'H', CAU  => 'H', CAC  => 'H', ATT  => 'I',
    AUU  => 'I', ATC  => 'I', AUC  => 'I', ATA  => 'I', AUA  => 'I',
    TTG  => 'L', UUG  => 'L', TTA  => 'L', UUA  => 'L', CTT  => 'L',
    CUU  => 'L', CTG  => 'L', CUG  => 'L', CTC  => 'L', CUC  => 'L',
    CTA  => 'L', CUA  => 'L', AAG  => 'K', AAA  => 'K', ATG  => 'M',
    AUG  => 'M', TTC  => 'F', UUC  => 'F', TTT  => 'F', UUU  => 'F',
    CCT  => 'P', CCU  => 'P', CCG  => 'P', CCC  => 'P', CCA  => 'P',
    TCT  => 'S', UCU  => 'S', TCG  => 'S', UCG  => 'S', TCC  => 'S',
    UCC  => 'S', TCA  => 'S', UCA  => 'S', AGT  => 'S', AGU  => 'S',
    AGC  => 'S', ACT  => 'T', ACU  => 'T', ACG  => 'T', ACC  => 'T',
    ACA  => 'T', TGG  => 'W', UGG  => 'W', TAC  => 'T', UAC  => 'T',
    TAT  => 'T', UAU  => 'T', GTT  => 'V', GUU  => 'V', GTG  => 'V',
    GUG  => 'V', GTC  => 'V', GUC  => 'V', GTA  => 'V', GUA  => 'V',
    TAA  => '*', UAA  => '*', TAG  => '*', UAG  => '*', TGA  => '*',
    UGA  => '*'
  );

  for (my $i = 0; $i < $seqLen; $i+=3) {
    my $codon = substr uc $sequence, $i, 3;
    next if( length($codon) % 3 != 0 );
    push @translation, $transTable{$codon};
  }
  # Return array of translated sequence
  if ($action) {
    return getAA(\@translation, $action);
  } else {
    return @translation; # default for just calling method with sequence
  }
}

=head2 getAA

  Arg [1]     : Protein sequence translation in array reference.

  Arg [2]     : Action to take- return, print, or save.

  Examples    : getAA(\@translation, 'return abv');
                getAA(\@translation, 'print name');
                getAA(\@translation, 'print');
                getAA(\@translation, 'save abv');

  Description : Gets amino acids' (AA) full name or abbreviation.

  Returntype  : Returns, prints, or saves AA sequence, with optional full name or abbreviation type.

  Status      : Stable

=cut
sub getAA {
  my ($translation, $action) = @_;
  my @translation = @$translation;
  $action =~ /(\w+)[\s+]?(\w+)?/;
  my $task = $1; my $type = $2;

  # EXPERIMENTAL
  # unless( $type ~~ [ qw(name abv) ] ) {
  #   croak "Your type '$type' is not supported.", $!;
  # }

  my %aminos = (
    A  => { name => 'Alanine', abv => 'Ala' },
    R  => { name => 'Arginine', abv => 'Arg' },
    N  => { name => 'Asparagine', abv  =>'Asn' },
    D  => { name => 'Aspartic Acid', abv  => 'Asp' },
    C  => { name => 'Cystine', abv => 'Cys' },
    Q  => { name => 'Glutamine', abv => 'Gln' },
    E  => { name => 'Glutamic Acid', abv => 'Glu' },
    G  => { name => 'Glycine', abv => 'Gly' },
    H  => { name => 'Histidine', abv => 'His' },
    I  => { name => 'Isoleucine', abv => 'Ile' },
    L  => { name => 'Leucine', abv => 'Leu' },
    K  => { name => 'Lysine', abv => 'Lys' },
    M  => { name => 'Methionine', abv => 'MET' },
    F  => { name => 'Phenylalanine', abv => 'Phe' },
    P  => { name => 'Proline', abv => 'Pro' },
    S  => { name => 'Serine', abv => 'Ser' },
    T  => { name => 'Thronine', abv => 'Thr' },
    W  => { name => 'Tryptophan', abv => 'Trp' },
    Y  => { name => 'Tyrosine', abv => 'Tyr' },
    V  => { name => 'Valine', abv => 'Val' },
    '*'  => { name => 'STOP', abv => '*' },
  );

  # Delegate action according to task and if type defined.
  # Logic for task being defined allows for more flexibility, or in
  # case action parameter is passed without action 'type' for 'task'
  if ($task eq 'return') {
    return @translation unless($type);
    return ( map { $aminos{$_}{$type} } @translation );
  } elsif ($task eq 'print') {
    print @translation and return unless($type);
    say $aminos{$_}{$type} for @translation;
  } elsif ($task eq 'save') {
    # $seqObj->writeFasta('translation.fasta') unless($type);
  } else {
    croak "Task '$task' is not supported", $!;
  }
  return;
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
