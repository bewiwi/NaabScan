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


require 'config.pl';
our $dbHost;
our $dbUser ;
our $dbBase ;
our $dbPwd ;
our $xmlFolder;
our $doneFolder;
our $nmapArg;
our $triggers;

my $die=0;
$|=1;

until ($die)
{
    my $dbh = DBI->connect('DBI:mysql:'.$dbBase, $dbUser, $dbPwd
    ) || die "Could not connect to database: $DBI::errstr";

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
        print Dumper $host;
        my $ip = $host->{ip};
        print "test";
        my $scan = NAABSCAN::NMAP->new($ip,$nmapArg,$xmlFolder);
        my $ret = $scan->scan();
        if ($ret)
        {
            my $updateStr = "UPDATE host SET scan = NULL WHERE ip = ? ";
            my $update = $dbh->prepare($updateStr);
            $update->execute($host->{ip});
        }
    }
    $request->finish();

    $dbh->disconnect();

    #wait 20 sec
    sleep(20);
}

