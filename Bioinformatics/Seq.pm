package Seq;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(); #functions exported by default
our @EXPORT_OK = qw(); #functions for explicit export

use strict; use warnings; use diagnostics; use feature qw(say);
use Carp;

use MyConfig;

use Bio::SeqIO;

# ==============================================================================
#
#   CAPITAN:        Andres Breton
#   FILE:           Seq.pm
#   USAGE:          Manipulate sequences
#   DEPENDENCIES:   - BioPerl modules
#
# ==============================================================================

=head1 NAME

Seq -

=head1 SYNOPSIS

Creation:
    use Seq;



=head1 DESCRIPTION



=head1 EXPORTS

=head2 Default Behaviors

Exports  subroutine by default

use Seq;

=head2 Optional Behaviors

Seq::;

=head1 FUNCTIONS

=head2 genbank2fasta

   Arg [1]    :

   Example    :

   Description:

   Returntype :

   Status     :

=head2 sub

  Arg [1]    :

  Example    :

  Description:

  Returntype :

  Status     :


=head1 COPYRIGHT AND LICENSE

Andres Breton © 2016

[LICENSE]

=head1 CONTACT

Please email comments or questions to Andres Breton me@andresbreton.com

=head1 SETTING PATH

If PERL5LIB was not set, do something like this:

use FindBin; use lib "$FindBin::RealBin/lib";

This finds and uses subdirectory 'lib' in current directoy as library location

=cut
# ==============================================================================

#-------------------------------------------------------------------------------
# SUBS
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ($file.gb);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes one (1) argument, a Genbank file to be
# converted into a FASTA file.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $output = ($file.fasta);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub genbank2fasta {
    my $filledUsage = 'Usage: genbank2fasta($file.gb);';
    @_ == 1 or croak wrongNumberArguments(), $filledUsage;

    my ($inFile) = @_;
    my ($outFile) = $inFile =~ /(.*).gb/;
    $outFile = $outFile . ".fasta";

    my $seqIn = Bio::SeqIO->new(-file => "$inFile", -format => 'genbank');
    my $seqOut = Bio::SeqIO->new(-file => ">$outFile", -format => 'fasta');

    while (my $seq = $seqIn->next_seq) {
        $seqOut->write_seq($seq);
    }
}

1;
