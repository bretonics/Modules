package Handlers;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(); #functions exported by default
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

Handlers - package to handle outputs

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
=head2 message

    Arg [1]     :

    Example     :

    Description : Return text message with color output

    Returntype  :

    Status      : Development

=cut

sub message {
    my %colors = (
        'red' => {
                'regular'   => "\e[0;31m",
                'bold'      => "\e[1;31m",
                },
        'green' => {
                'regular'   => "\e[0;32m",
                'bold'      => "\e[1;32m",
                },
        'yellow' => {
                'regular'   => "\e[0;33m",
                'bold'      => "\e[1;33m",
                },
        'blue' => {
                'regular'   => "\e[0;34m",
                'bold'      => "\e[1;34m",
                },
        'purple' => {
                'regular'   => "\e[0;35m",
                'bold'      => "\e[1;35m",
                },
        'cyan' => {
                'regular'   => "\e[0;36m",
                'bold'      => "\e[1;36m",
                },
        'white' => {
                'regular'   => "\e[0;37m",
                'bold'      => "\e[1;37m",
                },
        'reset'             => "\e[0m"
    );

	return;
}
1;
