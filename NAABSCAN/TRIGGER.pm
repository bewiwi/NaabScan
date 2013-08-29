package NAABSCAN::TRIGGER;
use Data::Dumper;
use JSON qw( encode_json );
use Env;

sub new
{
    my (
        $classe,
        $dbh,
        $scan,
        $triggers,
    )=@_;

    my $this = {
        "dbh" => $dbh,
        "scan" => $scan,
        "triggers" => $triggers,
        "commands" => @commands,
    };
    bless( $this, $classe );
    return $this;

}


sub checkTrigger
{
    my $this = shift ;
    my $retCode = 0;

    my $dbh = $this->{dbh};

    #TRIGGERS

    #Get IP
    my $sql = 'SELECT ip from host where id = '.$this->{scan}->{hostId}; 
    my $request = $dbh->prepare($sql);
    $request->execute();
    my $res = $request->fetchrow_arrayref();
    my $ip = $res->[0];

    my $triggers = $this->{triggers}; 
    foreach my $key (keys %$triggers)
    {
        my $trigger =  $triggers->{$key};

        #Check if trigger is ok
        $sql = $trigger->{sql};
        #PlaceHolders
        $sql =~ s/<scanid>/$this->{scan}->{id}/g;
        my $request2 = $dbh->prepare( $sql );    
        $request2->execute();

        while ( my $res2 =  $request2->fetchrow_arrayref() )
        {
            my $resScript = encode_json $res2;
            my $command = {
                key =>$key,
                ip =>$ip,
                row =>  $resScript,
                scan => $this->{scan}->getScanPlain(),
                script => $trigger->{script}
            };
            push(@{$this->{commands}},$command);
            $retCode = 1;
        }
    }
    return $retCode;
}

sub startCommand
{
    my $this = shift ;

    foreach my $command (@{$this->{commands}})
    {
        print 'Trigger "'.$command->{key}.'" OK pour l ip '.$command->{ip}."\n";
        print 'Exec : '.$command->{script}."\n";
        
        $command->{ip} =~s/\"/\\"/g; 
        $command->{row}=~s/\"/\\"/g;
        $command->{scan}=~s/\"/\\"/g;

        #I'm sorry for that but $ENV don't work 
        system(
            "export ip=\"$command->{ip}\"\n"
            ."export row=\"$command->{row}\"\n"
            ."export scan=\"$command->{scan}\"\n"
            .$command->{script}
        );
        if ( $? != 0 )
        {
            print "return code != 0 for ".$command->{key}; 
        }
    }
}

1;
