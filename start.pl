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

# Thread Part
my $scanQueue = new Thread::Queue;

#Start Nmap Worker
my $scanThread = async {
    while (my $scan = $scanQueue->dequeue) { 

        my $dbh = dbConnect;

        print "Popped $scan->{ip} off the queue\n";

        #change the state in database to inprogress (2)
        my $updateStr = "UPDATE host SET scan = 2 WHERE ip = ? ";
        my $update = $dbh->prepare($updateStr);
        $update->execute($scan->{ip});

        #Start scan
        $scan->scan();

        #change state to null
        print "Scan Finish $scan->{ip}\n";
        $updateStr = "UPDATE host SET scan = NULL WHERE ip = ? ";
        $update = $dbh->prepare($updateStr);
        $update->execute($scan->{ip});
        $dbh->disconnect();

    }
} for (1..$nmapThread);

#Start Nmap Checker
my $scanCheck = async {
    until ($die){

        #Connect dB
        my $dbh = dbConnect;

        #Check Host to Scan
        my $requestStr = "SELECT ip from host WHERE scan = 1";
        my $request = $dbh->prepare($requestStr);
        $request->execute();

        while ( my $host =  $request->fetchrow_hashref() )
        {
            my $ip = $host->{ip};
            my $scan = NAABSCAN::NMAP->new($ip,$nmapArg,$xmlFolder);

            #If scan is not program add him
            my $isInQueue = 0;    
            my $count=0;
            while(my $scanProg = $scanQueue->peek($count))
            {
                $count++;
                print "Compare  $scanProg->{ip} && $scan->{ip}\n";
                if($scanProg->{ip} eq $scan->{ip} )
                {
                    print "Already in pool $scan->{ip}\n";
                    $isInQueue = 1
                }
            }
            if ( $isInQueue == 0)
            {
                print "Add in pool $scan->{ip}\n";
                $scanQueue->enqueue($scan);
            }

        }
        $request->finish();
        $dbh->disconnect();
        sleep(5);
    }
};

#INIT
#change status of  scan in "progress" (2) to "to be scan" (1)
my $dbhTemp = dbConnect();
my $updateStr = "UPDATE host SET scan = 1 WHERE scan = 2 ";
my $update = $dbhTemp->prepare($updateStr);
$update->execute();
$dbhTemp->disconnect();


#MAIN LOOP
until ($die)
{

    #Connect DB
    my $dbh = dbConnect(); 

    #Import Host
    my $xmlImport = NAABSCAN::XML->new( $dbh, $xmlFolder,$doneFolder,$triggers);
    $xmlImport->scan();

    #disconnect DB
    $dbh->disconnect();

    #wait
    sleep(5);
}

