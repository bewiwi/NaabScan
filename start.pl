#!/usr/bin/perl
use strict;
use warnings;
use XML::Simple;
use DBI;
use Data::Dumper;
use Error;
use File::Basename;
use NAABSCAN::XML;
use NAABSCAN::NMAP;
use Thread qw(async);
use Thread::Queue;

require 'config.pl';
our $dbHost;
our $dbUser ;
our $dbBase ;
our $dbPwd ;
our $xmlFolder;
our $doneFolder;
our $nmapArg;
our $nmapThread;
our $triggers;

my $die=0;
$|=1;

sub dbConnect
{
    my $dbh = DBI->connect('DBI:mysql:'.$dbBase, $dbUser, $dbPwd
    ) || die "Could not connect to database: $DBI::errstr";
    return $dbh;
}

my $scanQueue = new Thread::Queue; 
my $scanThread = async {
    while (my $scan = $scanQueue->dequeue) { 

        my $dbh = dbConnect;

        print "Popped $scan->{ip} off the queue\n";
        my $ret = $scan->scan();
        if ($ret)
        {
            print "OK $scan->{ip}";
            my $updateStr = "UPDATE host SET scan = NULL WHERE ip = ? ";
            my $update = $dbh->prepare($updateStr);
            $update->execute($scan->{ip});
        }

    }
} for (1..$nmapThread);

my $dbh = dbConnect(); 

until ($die)
{

    #Import Host
    my $xmlImport = NAABSCAN::XML->new( $dbh, $xmlFolder,$doneFolder,$triggers);
    $xmlImport->scan();

    #Rescan Host
    my $requestStr = "SELECT ip from host WHERE scan = 1";
    my $request = $dbh->prepare($requestStr);
    $request->execute();
    my $host;
    while ( $host =  $request->fetchrow_hashref() )
    {
        my $ip = $host->{ip};
        my $scan = NAABSCAN::NMAP->new($ip,$nmapArg,$xmlFolder);
        #If scan is not program add him
        #TODO
        $scanQueue->enqueue($scan);
    }
    $request->finish();

    #wait 20 sec
    sleep(20);
}

$dbh->disconnect();
