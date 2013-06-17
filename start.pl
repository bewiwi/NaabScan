#!/usr/bin/perl
use strict;
use warnings;
use XML::Simple;
use DBI;
use Data::Dumper;
use Error;
use File::Basename;
use NAABSCAN::HOST;

require 'config.pl';
our $dbHost;
our $dbUser ;
our $dbBase ;
our $dbPwd ;
our $xmlFolder;
our $doneFolder;

my $dbh = DBI->connect('DBI:mysql:'.$dbBase, $dbUser, $dbPwd
                   ) || die "Could not connect to database: $DBI::errstr";

opendir(XMLRep,$xmlFolder) or die "$xmlFolder error";
while (defined(my $xmlFile=readdir XMLRep))
{
    my $filexmltest = $xmlFolder.'/'.$xmlFile;
    if(! -f $filexmltest || $filexmltest !~ /.*\.xml/){
        next
    }
    eval{
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
                next;
            }
            else
            {
                $NbScan->save();
            }

            foreach my $port ( @{ $host->{ports}[0]->{port} }  )
            {

                #service
                my @serviceNameArray =  keys %{$port->{service}};
                my $serviceName = $serviceNameArray[0];
                my $service = $port->{service}->{$serviceName};

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
                    $scriptInfo,
                    $service->{ostype}
                );
                $NbPort->save();
            }
        }
    }; 
    
    if ($@)
    {
        print 'error in '.$filexmltest." : ".$@;
    }
    else
    {
        print $xmlFile." OK\n";
        my $timestamp = time;
        rename($filexmltest,$doneFolder.'/'.$timestamp.'-'.$xmlFile);

    }
}
$dbh->disconnect();
