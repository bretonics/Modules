package Databases;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(startMongoDB insertData updateData readData removeData); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;

use MongoDB; use MongoDB::OID;

use MyConfig;

# =============================================
#
# 	CAPITAN:     Andres Breton, http://andresbreton.com
#	FILE:        Databases.pm
#
# =============================================

=head1 NAME

Databases - package to handle database connections

=head1 SYNOPSIS

Creation:
    use Databases;

=head1 DESCRIPTION


=head1 EXPORTS

=head2 Default Behaviors

Exports startMongoDB, insertData, updateData, readData, removeData subroutines by default

use Databases;

=head1 FUNCTIONS

=cut

my @dataFields = qw(_id accession sequence version locus organism seqLength gene proteinID translation);
#-------------------------------------------------------------------------------
# MAIN

=head2 startMongoDB

    Example     : $PID = startMongoDB($MONGODB, $outDir);

    Description : Start Mongo database service and return process ID

    Returntype  : Scalar

    Status      : Stable

=cut
sub startMongoDB {
    my $filledUsage = 'Usage: ' . (caller(0))[3] . '($MONGODB, $outDir)';
    @_ == 2 or croak wrongNumberArguments(), $filledUsage;

    my ($MONGODB, $outDir) = @_;
    my $pid;
    my $dbDir = $outDir."/db";
    `mkdir $dbDir` unless (-e $dbDir);
    my $mongoLog = $dbDir."/mongo.log";

    my $command = "mongod --dbpath $dbDir --logpath $mongoLog --fork";
    say "\nStarting MongoDB server...";
    my @result = `$command`; #get shell results
    if ($? == 0) { #Check return value
        $pid = $result[1] =~ /.+:\s(\d+)$/; $pid = $1; #get child PID
        say "MongoDB successfully started.\n";
        return $pid;
    } elsif ($? == 25600) { #Possible mongd already running
        say "*********FAILED";
        say "Could not fork. This was most likely caused by an instance of [mongod] already running.";
        # Check for Currently Running MongoDB Server
        my @mongdPS = `ps -e -o pid,args | grep \"mongod\"`;
        if ($mongdPS[0] =~ /^\s?(\d+)\s+mongod.*/) {
            $pid = $1;
            say "YES! Found running process: $mongdPS[0]";
            print "Would you like to continue (y/n)? ";
            my $response = lc <>; chomp $response;
            if ($response eq "yes" || $response eq "y") {
                return $pid;
            } else {
                exit;
            }
        } else {
            croak "Sorry, could not find instance of mongod running on system. Please check processes.", $!;
        }
    } else {
        croak "ERROR: Failed to execute $command\n Something happened that did not allow MongoDB server to start!", $!;
    }
}

=head2 insertData

    Example     : insertData($MONGODB, $COLLECTION, $id, $gi, $accession, $version, $locus, $organism, $sequence, $seqLen, $gene, $proteinID, $translation)

    Description : Insert document record in Mongo database

    Returntype  : Scalar List

    Status      : Stable

=cut
sub insertData {
    my $filledUsage = 'Usage: ' . (caller(0))[3] . '($MONGODB, $COLLECTION, $id, $gi, $accession, $version, $locus, $organism, $sequence, $seqLen, $gene, $proteinID, $translation)';
    @_ == 13 or croak wrongNumberArguments(), $filledUsage;

    my ($MONGODB, $COLLECTION, $id, $gi, $accession, $version, $locus, $organism, $sequence, $seqLen, $gene, $proteinID, $translation) = @_;

    my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    say "Storing data for ID ($id) into database $MONGODB";
    $collectionObj->insert({_id => $gi, #GI stored as Mongo UID
                        "accession" => $accession,
                        "version" => $version,
                        "locus" => $locus,
                        "organism" => $organism,
                        "seqLength" => $seqLen,
                        "sequence" => $sequence,
                        "gene" => $gene,
                        "proteinID" => $proteinID,
                        "translation" => $translation
                        })
}

=head2 updateData

    Example     : updateData($field, $value, $MONGODB, $COLLECTION);

    Description : Update document record in Mongo database

    Returntype  : Scalar List

    Status      : Stable

=cut
sub updateData {
    my $filledUsage = 'Usage: ' . (caller(0))[3] . '($field, $value, $MONGODB, $COLLECTION)';
    @_ == 4 or croak wrongNumberArguments(), $filledUsage;

    my ($field, $value, $MONGODB, $COLLECTION) = @_;
    say "\nUPDATING $field record [$value] in database...";
    say "Available fields are:\t@dataFields\n";
    print "What field do you want? ";
    my $fieldUpdate = <>; chomp $fieldUpdate;
    print "What is the NEW value for $fieldUpdate field? ";
    my $newValue = <>; chomp $newValue;
    my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    $collectionObj->update({$field => $value}, {'$set' => {$fieldUpdate => $newValue}});
    say "Document $value updated. $fieldUpdate field changed to $newValue.";
}

=head2 readData

    Example     : readData($field, $value, $MONGODB, $COLLECTION);

    Description : Read document record in Mongo database

    Returntype  : Scalar List

    Status      : Stable

=cut
sub readData {
    my $filledUsage = 'Usage: ' . (caller(0))[3] . '($field, $value, $MONGODB, $COLLECTION)';
    @_ == 4 or croak wrongNumberArguments(), $filledUsage;

    my ($field, $value, $MONGODB, $COLLECTION) = @_;
    my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    say "\nREADING field \"$field\" value \"$value\" from database...";
    my $cursor = $collectionObj->find({$field => $value});
    while (my $obj = $cursor->next) {
        say "Available fields are:\t@dataFields\n";
        print "What field do you want? ";
        my $response = <>; chomp $response;
        say "Here you go [$response]:\n", $obj->{$response};
    }
}

=head2 removeData

    Example     : removeData($field, $value, $MONGODB, $COLLECTION);

    Description : Remove document record in Mongo database

    Returntype  : Scalar List

    Status      : Stable

=cut
sub removeData {
    my $filledUsage = 'Usage: ' . (caller(0))[3] . '($field, $value, $MONGODB, $COLLECTION)';
    @_ == 4 or croak wrongNumberArguments(), $filledUsage;

    my ($field, $value, $MONGODB, $COLLECTION) = @_;
    say "REMOVING $field record [$value] in database...";
    my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    $collectionObj->remove({$field => $value});
}
#-------------------------------------------------------------------------------
# HELPERS

=head2 databaseConnection

    Arg [1]     : No arguments

    Example     : databaseConnection($MONGODB, $COLLECTION)

    Description : Start connection to Mongo database server

    Returntype  : Scalar List

    Status      : Stable

=cut
sub databaseConnection {
    my $filledUsage = 'Usage: ' . (caller(0))[3] . '($MONGODB, $COLLECTION)';
    @_ == 2 or croak wrongNumberArguments(), $filledUsage;

    my ($MONGODB, $COLLECTION) = @_;
    my $client = MongoDB::MongoClient->new; #connect to local db server
    my $db = $client->get_database($MONGODB); #get MongoDB database
    my $collectionObj = $db->get_collection($COLLECTION); #get collection
    return $collectionObj;
}


=head1 COPYRIGHT AND LICENSE

Andres Breton (C) 2016

[LICENSE]

=head1 CONTACT

Please email comments or questions to Andres Breton, me@andresbreton.com

=head1 SETTING PATH

If PERL5LIB was not set, do something like this:

use FindBin; use lib "$FindBin::RealBin/lib";

This finds and uses subdirectory 'lib' in current directoy as library location

=cut

1;
