package MyConfig;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(wrongNumberArguments); #functions to export

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;

use FindBin; use lib "$FindBin::RealBin";
use Readonly;

# =============================================================================
#
#   CAPITAN:    Andres Breton
#   FILE:       MyConfig.pm
#   USAGE:      Configuration module
#
# =============================================================================

#-------------------------------------------------------------------------
# VARIABLES
Readonly my $BAD_NUM_ARGUMENTS  => "\nIncorrect number of arguments in call to subroutine. ";

sub wrongNumberArguments {
    my $filledUsage = ' Usage: ' . (caller(0))[3] . '()';
    # test the number of arguments passed in were correct
    @_ == 0 or confess $BAD_NUM_ARGUMENTS, $filledUsage ;
    return $BAD_NUM_ARGUMENTS;
}
1;

=head1 NAME

MyConfig - package returning $BAD_NUM_ARGUMENTS when subroutine called with wrong number of arguments.

=head1 SYNOPSIS

Creation:
    use MyConfig;

    sub getFH {
        my ($operation, $file) = @_;

        my $filledUsage = 'Usage: ' . (caller(0))[3] . '($operation, $file)';
        #test the number of arguments passed in were correct
        @_ == 2 or confess wrongNumberArguments() , $filledUsage;

        return;
    }

=head1 DESCRIPTION

This module was designed to be used as a config file returning a string warning user that a subroutine was called with the incorrect number of arguments.

=head1 EXPORTS

=head2 Default Behavior

Exports wrongNumberArguments() subroutine by default

use MyConfig;

=head1 FUNCTIONS

=head2 wrongNumberArguments

    Arg [1]     : No arguments

    Example     : @_ == 2 or confess wrongNumberArguments() , $filledUsage;

    Description : This will return the error string defined by constant $BAD_NUM_ARGUMENTS.
                  One can use to get a generic string for error handling when the incorrect number of parameters is called in a Module.

    Returntype  : Scalar

    Status      : Stable

=cut

=head1 COPYRIGHT AND LICENSE

Andres Breton 2016

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

Please email comments or questions to Andres Breton me@andresbreton.com

=head1 SETTING PATH

If PERL5LIB was not set, do something like this:

use FindBin; use lib "$FindBin::RealBin";

This finds and uses current directoy as library location

=cut
