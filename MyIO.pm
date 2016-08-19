package MyIO;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(getFH mkDir); #functions to export
our @EXPORT_OK = qw(); #functions to export

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;

use FindBin; use lib "$FindBin::RealBin";

use MyConfig;

# =============================================================================
#
#   CAPITAN:    Andres Breton
#   FILE:       MyIO.pm
#   USAGE:      File IO package
#
# =============================================================================


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ($operation, $FILE);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes an operation (read/write) to perform on
# when opening file passed. Also checks if file exists.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = ($FH)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub getFH {
    my ($operation, $file) = @_;
    my $filledUsage = 'Usage: ' . (caller(0))[3] . '($operation, $file)';
    @_ == 2 or croak wrongNumberArguments(), $filledUsage;
    croak "File provided is a directory" if (-d $file);

    my $FH;
    # Operation, what should I do with file?
    if ($operation eq "<") { #read file
        open($FH, "<", $file) or croak "Could not open $file for reading.", $!;
        return $FH; #return read file handle
    } elsif ($operation eq ">") { #write file
        open($FH, ">", $file) or croak "Could not open $file for writing.", $!;
        return $FH; #return write file handle
    } elsif ($operation eq ">>") { #append to file
        open($FH, ">>", $file) or croak "Could not open $file for writing (append).", $!;
        return $FH; #return write file handle
    } else {
        croak "You did not provide a correct file operation, \'$operation\' passed. You need \'<\', \'>\', or \'>>\' to read/write/append respectively.";
    }
    return;
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ($outDir);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes 1 argument, a directory name to create.
# Makes directory if non-existent, warns otherwise
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $output = Directory in filesystem
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub mkDir {
    my ($outDir) = @_;
    my $filledUsage = 'Usage: ' . (caller(0))[3] . '($outDir)';
    @_ == 1 or croak wrongNumberArguments(), $filledUsage;
    
    if (!-e $outDir) {
        mkdir $outDir;
    } else {
        warn "Directory '$outDir' already exists.";
    }
    return $outDir;
}

1;


=head1 NAME

MyIO - package to handle opening files and passing filehandles

=head1 SYNOPSIS

Creation:
    use MyIO;

    my $infile = "test.txt";
    my $fh = getFH("<", $infile);

=head1 DESCRIPTION

This module was designed to handle opening file operations and return filehandles.

=head1 EXPORTS

=head2 Default Behaviors

Exports getFH subroutine by default

use MyIO;

=head2 Optional Behaviors

MyIO::mkDir("DirName");

=head1 FUNCTIONS

=head2 getFH

   Arg [1]    : Type of file to open, reading '<', writing '>', appending '>>' and file

   Example    : my $fh = getFH('<', $infile);

   Description: This returns a filehandle for the file passed. This function
                can be used to open, write, and append, and get the filehandle in return.

   Returntype : A filehandle

   Status     : Stable

=head2 mkDir

  Arg [1]    : A directory name that needs to be created

  Example    : mkDir("assignment_output");

  Description: This function will make the directory passed if it does not exist if you have privileges

  Returntype : undef

  Status     : Stable


=head1 COPYRIGHT AND LICENSE

Andres Breton 2015

GNU V2
The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Lesser General Public License instead.)  You can apply it to
your programs, too.

=head1 CONTACT

Please email comments or questions to Andres Breton breton.a@husky.neu.edu

=head1 SETTING PATH

If PERL5LIB was not set, do something like this:

use FindBin; use lib "$FindBin::RealBin";

This finds and uses current directoy as library location

=cut
