#!/usr/bin/perl
use strict;
use warnings;
use XML::Simple;
use DBI;
use Data::Dumper;
use NAABSCAN::HOST;

require 'config.pl';
our $dbHost;
our $dbUser ;
our $dbBase ;
our $dbPwd ;

my $dbh = DBI->connect('DBI:mysql:'.$dbBase, $dbUser, $dbPwd
                   ) || die "Could not connect to database: $DBI::errstr";

my @files = <./xml/*.xml>;
foreach my $filexmltest (@files)
{
    my $parser = XML::Simple->new( KeepRoot => 1,ForceArray=>1 );
    my $xmlScan = $parser->XMLin($filexmltest);

    my $command =  $xmlScan->{nmaprun}[0]->{args};
    foreach my $host ( @{ $xmlScan->{nmaprun}[0]->{host} } )
    {

        my $NbHost = new NAABSCAN::HOST($dbh,$host->{address}[0]->{addr});
        $NbHost->save();

        my $starttime =  $host->{'starttime'};
        my $NbScan = new NAABSCAN::SCAN($dbh,$starttime,$NbHost->{id});
        if ( $NbScan->{id} )
        {
            print 'Scan already in database '.$host->{address}[0]->{addr}."\n";
        }
        $NbScan->save();

        foreach my $port ( @{ $host->{ports}[0]->{port} }  )
        {

            #my $protocol = $port->{protocol};
            my $portNumber = $port->{portid};
            my $state = $port->{state}[0]->{state};
            
            #service
            my @serviceNameArray =  keys %{$port->{service}};
            my $serviceName = $serviceNameArray[0];
            
            my $service = $port->{service}->{$serviceName};
           
            my $product = $service->{product};
            my $productVersion = $service->{version};
            my $serviceExtra = $service->{extrainfo};
            my $ostype = $service->{ostype};

            my $scriptInfo='';
            if( $port->{script})
            {
                for my $key ( keys %{ $port->{script} } )
                {
                    my $script = $port->{script}->{$key};
                    $scriptInfo .= $key.' '.$script->{output}."\n";
                }
            }

            my $NbPort = new NAABSCAN::PORT(
                $dbh,
                $NbScan->{id},
                $port->{protocol},
                $port->{portid},
                $port->{state}[0]->{state},
                $serviceName,
                $service->{product},
                $service->{version},
                $service->{extrainfo},
                $service->{ostype}
            );
            $NbPort->save();
        }
    }
}
$dbh->disconnect();
