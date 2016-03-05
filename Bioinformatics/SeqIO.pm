package BioIO::SeqIO;

use diagnostics; use feature qw(say);
use Carp;

use FindBin; use lib "$FindBin::RealBin";

use Moose; use MooseX::StrictConstructor;

use BioIO::MyIO; use BioIO::Config; use BioIO::Seq; use FinalTypes::MyTypes

# =============================================================================
#
#   CAPITAN: Andres Breton
#   FILE: SeqIO.pm
#   USAGE:
#
# =============================================================================

#-------------------------------------------------------------------------
# ATTRIBUTES
#Public
has "filename" => (is => "ro", isa => "Str", required => 1);
has "fileType" => (is => "ro", isa => "FileType", required => 1,);
#Private
has "_gi" => (is => "ro", isa => "ArrayRef",
              writer => "_writer_gi", init_arg => undef);
has "_seq" => (is => "ro", isa => "HashRef",
               writer => "_writer_seq", init_arg => undef);
has "_def" => (is => "ro", isa => "HashRef",
               writer => "_writer_def", init_arg => undef);
has "_accn" => (is => "ro", isa => "HashRef",
                writer => "_writer_accn", init_arg => undef);
has "_current" => (is => "ro", isa => "Int", default => 0,
                   writer => "_writer_current", init_arg => undef);


#-------------------------------------------------------------------------
# METHODS

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# _getGenbankSeqs: Private to the class, and called by the BUILD method;
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This method fills in the SeqIO attributes with _gi, _accn,
# _def, and _seq attributes created
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub _getGenbankSeqs {
    my $filledUsage = 'Usage: $self->_getGenbankSeqs;';
    @_ == 1 or croak wrongNumberArguments(), $filledUsage;

    my ($self) = @_;
    my $FH = getFh("<", $self->filename);
    my ($gi, $seq, @GIs, %sequence, %accession, %definition); #variables
    $/ = "//\n"; #set file delimiter to GenBank file record separator

    # Get Attribute Values
    while (<$FH>) {
        #Get GI and Accession
        if ($_ =~ /VERSION\s+(\S+)\s+GI:(.+)/) {
            $gi = $2;
            $accession{$gi} = $1;
            push @GIs, $gi;
        }
        #Get Sequence
        if ($_ =~ /ORIGIN\s*(.*)\/\//s) {
            $seq = $1;
            $seq =~ s/[\s\d]//g; #remove spaces/numbers from sequence
            $sequence{$gi} = uc $seq;
        }
        #Get Definition
        if ($_ =~ /DEFINITION\s*(.*)\.\nACCESSION/s) {
            my $def = $1;
            $def =~ s/\n//g; #remove new lines
            $def =~ s/\s+/ /g; #replace multiple spaces
            $definition{$gi} = $def;
        }
    } close $FH;
    $/ = "\n";  #set back line separator

    # Set SeqIO Attributes
    $self->_writer_gi(\@GIs);
    $self->_writer_seq(\%sequence);
    $self->_writer_accn(\%accession);
    $self->_writer_def(\%definition);

    return;
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# _getFastaSeqs: private to the class, and called by the BUILD method
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This method reads seqs and info, filling in the SeqIO attributes
# with _gi, _accn, _def, and _seq attributes created
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = ();
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub _getFastaSeqs {
    my $filledUsage = 'Usage: $self->_getFastaSeqs;';
    @_ == 1 or croak wrongNumberArguments(), $filledUsage;

    my ($self) = @_;
    my $FH = getFh("<", $self->filename);
    my (@GIs, %sequence, %accession, %definition); #variables

    $/ = ">"; #set FASTA record separator
    while (<$FH>) {
        next if($. == 1); #deal with first line
        my ($headerLine, @seqLines) = split /\n/, $_; #split header and sequence lines
        $headerLine =~ /^gi\|(.+)\|\w+\|(.+)\|(.+)/;
        push @GIs, $1;
        $accession{$1} = $2;
        $definition{$1} = $3;
        $sequence{$1} = join("",@seqLines);
    } close $FH;
    $/ = "\n"; #reset record separator

    # Set SeqIO Attributes
    $self->_writer_gi(\@GIs);
    $self->_writer_seq(\%sequence);
    $self->_writer_accn(\%accession);
    $self->_writer_def(\%definition);

    return;
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $seqIOobj->nextSeq()
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This method tests if there is another sequence left in the
# object, creating a new Seq object or returning undef if non left
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub nextSeq {
    my $filledUsage = 'Usage: my $seqObj = $seqIOobj->nextSeq()';
    @_ == 1 or croak wrongNumberArguments(), $filledUsage;

    my ($self) = @_;
    # Get Attribute Values
    my @gis = @{$self->_gi};
    my %seq = %{$self->_seq};
    my %def = %{$self->_def};
    my %accn = %{$self->_accn};
    my $current = $self->_current; #current iteration
    my $numSeqs = scalar ( keys %seq ); #total number of sequences in object

    if ( $numSeqs > $current ) {
        my $gi = $gis[$current]; #get gi for current sequence
        my $seqObj = BioIO::Seq->new( gi => $gi,
                                      seq => $seq{$gi},
                                      def => $def{$gi},
                                      accn => $accn{$gi} );
        $self->_writer_current($self->_current + 1); #increment _current attribute to track next sequence
        return $seqObj;
    } else { return undef; }
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# The BUILD method is called after the object is constructed,
# but before it is returned to the caller.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub BUILD {
    my ($self) = @_;
    if ( $self->fileType eq "genbank" ) {
        $self->_getGenbankSeqs;
    } elsif ( $self->fileType eq "fasta" ) {
        $self->_getFastaSeqs;
    } else {
        warn "File type not recognized.", $self->fileType, "passed";
    }
}
1;
