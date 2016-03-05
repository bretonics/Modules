package BioIO::Kinases;

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;

use FindBin; use lib "$FindBin::RealBin";

use BioIO::MyIO; use BioIO::Config;

# =============================================================================
#
#   CAPITAN: Andres Breton
#   FILE: Kinases.pm
#   USAGE:
#
# =============================================================================

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = BioIO::Kinases->new($fileInName);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# A constructor, when you build a new obj, it calls _readKinases.
# The object has two attributes 'aoh' which stores an Array of Hashes,
# and 'numberOfKinases' which stores the number of kinases in the object
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = blessed object for class
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub new {
    my $filledUsage = 'Usage: BioIO::Kinases->new($file)';
    @_ == 2 or croak wrongNumberArguments(), $filledUsage;

    my ($class, $fileInName) = @_;
    my $aoh = _readKinases($fileInName) if ($fileInName); #private class method used to create the array of hashes
    return bless (  {   _aoh => $aoh,
                        _numberOfKinases => scalar @$aoh,
                    }, $class
                );
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ($fileInName);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes 1 argument, a file containing kinase info.
# It goes through the field, creating an AoH, where each hash
# contains the kinase info for one line
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = (\$AoH);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub _readKinases {
    my $filledUsage = 'Usage: $aoh = _readKinases($fileInName)';
    @_ == 1 or croak wrongNumberArguments(), $filledUsage;

    my ($file) = @_;
    my @AoH;
    my @fields = qw/symbol name date location omim_accession/;
    my $FH = getFh("<", "INPUT/".$file);
    while (<$FH>) {
        my %hash;
        @hash{@fields} = split /\|/, $_; #add field:fileEntry (key:value) to hash
        push @AoH, \%hash; #add hash to array
    } close $FH;
    return \@AoH;
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ($fileOutName, ['symbol', 'name', 'location');
# $input = ($fileOutName, ['symbol', 'name', 'location', 'omim_accession']);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes 2 arguments, a filename indicating output
# and a reference to an array (list of fields). Prints all the
# kinases in a Kinases object, according to the requested list
# of keys
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $output = Prints all kinases to file
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub printKinases {
    my $filledUsage = 'Usage: $kinaseObj->printKinases($fileOutName, [\'symbol\',\'name\',\'location\'] )';
    @_ == 3 or croak wrongNumberArguments(), $filledUsage;

    my ($self, $fileOutName, $refArrFields) = @_;
    my $FH = getFh(">", "OUTPUT/".$fileOutName);
    foreach ( @{ $self->getAoh } ) { #get array of hashes reference
        for my $field (@$refArrFields) { #iterate through fields passed
            $_->{$field} =~ s/\s+$//; #remove trailing space for weird cases
            print $FH "$_->{$field}\t";
        }
        print $FH "\n"; #new line for new entry (kinase)
    }
    return;
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ( { name=>'tyrosine' } );
# $input = ( { name=>'tyrosine', symbol=>'EPLG4' } );
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes 1 argument, a hash reference with field-criterion
# for filtering the Kinases of interest. It returns a new Kinases
# object which contains the kinases meeting the requirement
# (filter parameters) passed into the method.  This method must
# use named parameters, since you could pass any of the keys to
# the hashes found in the AOH: symbol, name, location, date,
# omim_accession. If no filters are passed in, then it would just
# return another Kinases object with all the same entries. This
# could be used to create an exact copy of the object. Remember,
# creating a exact copy of an object, requires a new object with
# new data, you can't just create a copy,
# i.e. $kinaseObj2 = $kinaseObj would not work.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = Blessed object for $self class
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub filterKinases {
    my $filledUsage = "Usage: ( { name=>'tyrosine', symbol=>'EPLG4' } )";
    @_ == 2 or croak wrongNumberArguments(), $filledUsage;

    my ($self, $filterFields) = @_;
    return bless ($self , ref($self)) unless(keys %$filterFields); #return copy of object w/ same entries if no filters passed
    my @filteredAoh;
    foreach my $hash( @{ $self->getAoh } ) { #get array of hashes reference
        for my $key (keys $filterFields) { #iterate through fields passed
            if ($hash->{$key} =~ /$filterFields->{$key}/i) { #compare values of kinase and filter field values
                push @filteredAoh, $hash if !grep{ $_ eq $hash } @filteredAoh; #push hash with filter match to array if hash !exist in array
                #need to check if hash already present in case >1 filters passed
                #matches the same entry
            }
        }
    }
    return bless (  {   _aoh => \@filteredAoh,
                        _numberOfKinases => scalar @filteredAoh,
                    }, ref($self)
                );
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ( @{ $self->getAoh } );
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes no arguments but $self object to get the
# array of hashes attribute value
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = aoh attribute value
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub getAoh {
    my $filledUsage = 'Usage: $kinaseObj->getAoh';
    @_ == 1 or croak wrongNumberArguments(), $filledUsage;
    return($_[0] -> {_aoh});
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ($self->getNumberOfKinases);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes no arguments but $self object to get the
# numberOfKinases attribute value
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $output = numberOfKinases attribute value
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub getNumberOfKinases {
    my $filledUsage = 'Usage: @{ $kinaseObj->getNumberOfKinases }';
    @_ == 1 or croak wrongNumberArguments(), $filledUsage;
    return($_[0] -> {_numberOfKinases});
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $input = ($index);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This function takes 1 argument, an index that returns the
# element of the Array of Hashes in the Kinase instance.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# $return = (\@hash);
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub getElementInArray {
    my $filledUsage = 'Usage: )';
    @_ == 2 or croak wrongNumberArguments(), $filledUsage;

    my ($self, $index) = @_;
    return @{$self->getAoh}[$index] if(@{$self->getAoh}[$index]); #return reference to hash element in array $index if $index exists in array
    return; #return if $index not present
}
1;

=head1 NAME

BioIO::Kinanse -

=head1 SYNOPSIS

Creation:
    use BioIO::Kinanse;

    my $kinaseObj = BioIO::Kinases->new($fileInName);

=head1 DESCRIPTION

This module was designed as an Object Oriented program with Class 'BioIO::Kinases' in order to create a kinase object.

=head1 EXPORTS

=head2 Default Behaviors

use BioIO::Kinanse;

=head1 METHODS

=head2 new

   Arg [1]    : A file name containing kinase entries, 1 per line.

   Example    : my $kinaseObj = BioIO::Kinases->new($fileInName);

   Description: A constructor to build a new object that calls _readKinases to
                get an Array of Hashes for each kinase entry in file.

   Returntype : Blessed object for class.

   Status     : Stable

=head2 printKinases

Arg [1]    :  Output file name and anonymous array of desired fields to be printed.

Examples    : $kinaseObj->printKinases($fileOutName,
              ['symbol','name','location'] )';

Description: Gets array of hashes reference to retrieve fields passed.

Returntype : Prints desired kinase fields to output file.

Status     : Stable

=head2 filterKinases

Arg [1]    : Hash reference with field-criterion for filtering the Kinases of interest

Example    : $kinaseObj->filterKinases( { name=>'tyrosine', symbol=>'EPLG4' } );

Description: Returns a new Kinases object which containing the kinases passing
             the filter fields or a copy of the object if no filters passed.

Returntype : Blessed object for $self class

Status     : Stable

=head2 getAoh

Arg [1]    : $self object

Example    : $kinaseObj->getAoh;

Description: Get the array of hashes attribute value for object

Returntype : 'aoh' attribute value

Status     : Stable

=head2 getNumberOfKinases

Arg [1]    : $self object

Example    : $self->getNumberOfKinases;

Description: Get the number of kinases attribue value for object

Returntype : 'numberOfKinases' attribute value

Status     : Stable

=head2 getElementInArray

Arg [1]    : An index

Example    : $kinaseObj->getElementInArray('25');

Description: Takes an index and returns the element, a reference to a hash, of
             the Array of Hashes in the Kinase instance for the index passed. Returns otherwise.

Returntype : Reference to hash element in array $index

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
