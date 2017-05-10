package Bioinformatics::Seq;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(genbank2fasta);
our @EXPORT_OK = qw();

use strict; use warnings; use diagnostics; use feature qw(say);
use Carp;
use Bio::SeqIO;

# Own Modules (https://github.com/bretonics/Modules)
use MyConfig;

# ==============================================================================
#
#   CAPITAN:        Andres Breton, http://andresbreton.com
#   FILE:           Seq.pm
#   LICENSE:
#   USAGE:          Manipulate sequences
#   DEPENDENCIES:   - BioPerl modules
#
# ==============================================================================

=head1 NAME

Seq - package for sequence manipulation.

=head1 SYNOPSIS

use Bioinformatics::Seq;

=head1 DESCRIPTION

This module was designed for use in common sequence manipulation tasks.

=head1 EXPORTS

=head2 Default Behaviors

use Bioinformatics::Seq;

Exports 'genbank2fasta' function by default.

=head2 Optional Behaviors



=head1 FUNCTIONS

=head2 genbank2fasta

   Arg [1]      : GenBank file

   Example      : genbank2fasta($file.gb);

   Description  : Converts Genbank file to fasta file format.

   Returntype   : NULL, fasta file written.

   Status       : Stable
=cut

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ($file.gb);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes one (1) argument, a GenBank file to be
# converted into a FASTA file.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $output = ($file.fasta);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub genbank2fasta {
   my $filledUsage = 'Usage: genbank2fasta($file.gb);';
   @_ == 1 or croak wrongNumberArguments(), $filledUsage;

   my ($inFile)   = @_;
   my ($outFile)  = $inFile =~ /(.*).gb/;
   $outFile = $outFile . ".fasta";

   my $seqIn   = Bio::SeqIO->new( -file => $inFile, -format => 'genbank' );
   my $seqOut  = Bio::SeqIO->new( -file => ">$outFile", -format => 'fasta' );

   while (my $seq = $seqIn->next_seq) {
       $seqOut->write_seq($seq);
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
