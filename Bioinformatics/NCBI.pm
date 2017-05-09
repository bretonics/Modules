package Bioinformatics::Eutil;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(getNCBIfile);
our @EXPORT_OK = qw();

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;
use Bio::DB::EUtilities;

# Own Modules (https://github.com/bretonics/Modules)
use MyConfig;

# ==============================================================================
#
#   CAPITAN:        Andres Breton, http://andresbreton.com
#   FILE:           NCBI.pm
#   LICENSE:
#   USAGE:          Acces NCBI's E-utilities
#   DEPENDENCIES:   - BioPerl modules
#
# ==============================================================================

=head1 NAME

Eutil - package interface for accessing NCBI's servers.

=head1 SYNOPSIS

use Bioinformatics::Eutil;

=head1 DESCRIPTION

This module was designed to utilize NCBi's E-utilities to access NCBI data.

=head1 EXPORTS

=head2 Default Behaviors

use Bioinformatics::Eutil;

Exports 'getNCBIfile' function by default.

=head2 Optional Behaviors



=head1 FUNCTIONS

=head2 getNCBIfile

  Arg [1]     : $ID, $outDir, $FORCE, $DATABASE, $TYPE, $email

  Example     : ($NCBIfile, $NCBIstatus) = getNCBIfile($id, $outDir, $FORCE, $DATABASE, $TYPE, $email);

  Description : Use NCBI's E-utilities to fetch file from server

  Returntype  : Scalar list (2)

  Status      : Stable

=cut
sub getNCBIfile {
    my $filledUsage = 'Usage: ' . (caller(0))[3] . '($ID, $outDir, $FORCE, $DATABASE, $TYPE, $email)';
    @_ == 6 or confess wrongNumberArguments(), $filledUsage;

    my ($ID, $outDir, $FORCE, $DATABASE, $TYPE, $email) = @_;
    my $outFile = $outDir ."/$ID." .$TYPE;

    my $eutil = Bio::DB::EUtilities->new(
            -eutil => "efetch",
            -db => $DATABASE,
            -id => $ID,
            -email => $email,
            -rettype => $TYPE,
    );

    # Fetch
    say "\nFetching data from NCBI for ID $ID. Wait...\n";
    $eutil->get_Response( -file => $outFile);
    sleep(3); #Don't overload NCBI requests
    return ($outFile, 1);
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
