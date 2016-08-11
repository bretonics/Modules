package Handlers;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(mkDir); #functions exported by default
our @EXPORT_OK = qw(); #functions for explicit export

use strict; use warnings; use diagnostics; use feature qw(say);
use Carp;

use MyConfig;

# ==============================================================================
#
#   CAPITAN:	Andres Breton, http://andresbreton.com
#   FILE		Handlers.pm
#   LICENSE:
#   USAGE:		Handle outputs
#
# ==============================================================================

=head1 NAME

Handlers - package handler for outputs

=head1 SYNOPSIS

Creation:
    use Handlers;

=head1 DESCRIPTION


=head1 EXPORTS

=head2 Default Behaviors

Exports $SUB subroutine by default

use Handlers;

=head2 Optional Behaviors

Handlers::;

=head1 FUNCTIONS

=cut

#-------------------------------------------------------------------------------
# MAIN

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
=head2 mkDir

    Arg [1]     : Name of output directory desired

    Example     : mkDir("Data");

    Description : Create directory unless already present

    Returntype  : NULL

    Status      : Stable

=cut

sub mkDir {
	my ($outDir) = @_;
	`mkdir $outDir` unless(-e $outDir);
	return;
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
=head2 textOut

    Arg [1]     : 

    Example     : 

    Description : 

    Returntype  : 

    Status      : Development

=cut

sub textOut {

	return;
}
