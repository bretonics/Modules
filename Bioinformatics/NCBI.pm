package Eutil;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(getNCBIfile); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;
use Bio::DB::EUtilities;

# =============================================
#
# 	MASTERED BY: Andres Breton
#	FILE: eutil.pm
#
# =============================================

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# MAIN

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
1;
