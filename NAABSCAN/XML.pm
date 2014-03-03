package NAABSCAN::XML;
use XML::Simple;
use Data::Dumper;
use Error;
use File::Basename;
use NAABSCAN::HOST;


sub new
{
    my (
        $classe,
        $dbh,
        $xmlFile,
        $doneFolder,
        $geoipDatabase,
    )=@_;

    my $this = {
        "dbh" => $dbh,
        "xmlFile" => $xmlFile,
        "doneFolder" => $doneFolder,
        "geoipDatabase" => $geoipDatabase,
    };
    bless( $this, $classe );
    return $this;

}

sub  getGeoInformation
{
    my $this = shift ;
    my $ip = shift;
    if ( -e $this->{geoipDatabase} )
    {  
        use Geo::IP;
        my $gi = Geo::IP->open($this->{geoipDatabase}, GEOIP_STANDARD);
        my $geoInfo = $gi->record_by_addr($ip);
        return {
            "country" => $geoInfo->country_code,
            "longitude" => $geoInfo->longitude,
            "latitude" => $geoInfo->latitude,
        };
    }else{
        print("ERROR geoipDAtabase not found");
        return 0;
    }
}

sub scan
{
    my $this = shift ;
    my $dbh = $this->{dbh};
    my $xmlFile = $this->{xmlFile};
    my $doneFolder = $this->{doneFolder};

    my $NbScan;
    my $NbHost;

    my @scans;

    eval{
        my $parser = XML::Simple->new( KeepRoot => 1,ForceArray=>1 );
        my $xmlScan = $parser->XMLin($xmlFile);

        my $command =  $xmlScan->{nmaprun}[0]->{args};
        foreach my $host ( @{ $xmlScan->{nmaprun}[0]->{host} } )
        {

            $NbHost = new NAABSCAN::HOST($dbh,$host->{address}[0]->{addr});
            $NbHost->save();
            my $starttime =  $host->{'starttime'};
            $NbScan = new NAABSCAN::SCAN($dbh,$starttime,$NbHost->{id});
            if ( $NbScan->{id} )
            {
                print 'Scan already in database '.$host->{address}[0]->{addr}."\n";
                next;
            }
            else
            {
                my $geoInfo = $this->getGeoInformation($host->{address}[0]->{addr});
                if ( $geoInfo )
                {
                    $NbScan->addGeoInfo(
                                    $geoInfo->{country},
                                    $geoInfo->{longitude},
                                    $geoInfo->{latitude}
                    );
                } 
                $NbScan->save();
            }

            push(@scans,$NbScan);

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
        print 'error in '.$xmlFile." : ".$@;
    }
    else
    {
        print $xmlFile." OK\n";
        my $timestamp = time;
        rename($xmlFile,$doneFolder.'/'.$timestamp.'-'.$NbHost->{addr}.'.xml');
    }
    return @scans;
}

1;
