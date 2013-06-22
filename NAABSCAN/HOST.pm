package NAABSCAN::HOST;
use Data::Dumper;

sub new
{
    my ( $classe, $dbh ,$addr ) = @_;
    my $this = {
        "dbh" => $dbh,
        "addr"    => $addr,
        "id" => ''
    };
    bless( $this, $classe );
    $this->getId();
    return $this;
}

sub getId
{
    my $this = shift ;
    my $requestStr = "SELECT id from host WHERE ip = ?";
    my $request = $this->{dbh}->prepare($requestStr);
    $request->execute($this->{addr});
    $this->{id} =  $request->fetchrow_array();

}

sub save
{
    my $this = shift ;
    if (! $this->{id})
    {
        $this->{dbh}->do('INSERT INTO host (ip) VALUES (?)',undef,$this->{addr});
        $this->getId();
    }
    return $this->{id};
}

package NAABSCAN::SCAN;
use Data::Dumper;

sub new
{
    my ( $classe, $dbh ,$date,$hostId ) = @_;
    my $this = {
        "dbh" => $dbh,
        "date"    => $date,
        "hostId" => $hostId
    };
    bless( $this, $classe );
    $this->getId();
    return $this;
}

sub getId
{
    my $this = shift ;
    my $requestStr = "SELECT id from scan WHERE host_id = ? AND date = ?";
    my $request = $this->{dbh}->prepare($requestStr);
    $request->execute($this->{hostId},$this->{date});
    $this->{id} =  $request->fetchrow_array();

}

sub save
{
    my $this = shift ;
    if (! $this->{id})
    {
        my $request = $this->{dbh}->prepare('INSERT INTO scan (host_id,date) VALUES (?,?)');
        $request->execute($this->{hostId}, $this->{date} );
        $this->getId();
    }
    return $this->{id};
}

package NAABSCAN::PORT;

sub new
{
    my (
        $classe,
        $dbh ,
        $scanId,
        $protocol,
        $portNumber,
        $state,
        $serviceName,
        $product,
        $productVersion,
        $serviceExtra,
        $scriptInfo,
        $ostype
    ) = @_;
   
    my $this = {
        "dbh" => $dbh,
        "scanId" => $scanId,
        "protocol" => $protocol,
        "portNumber"=>$portNumber,
        "state"=>$state,
        "serviceName"=>$serviceName,
        "product"=>$product,
        "productVersion"=> $productVersion,
        "serviceExtra"=>$serviceExtra,
        "scriptInfo"=>$scriptInfo,
        "ostype" =>$ostype

    };
    bless( $this, $classe );
    return $this;
}


sub save
{
    my $this = shift ;
    if (! $this->{id})
    {
        $this->{dbh}->do(
            'INSERT INTO port (`scan_id`, `protocol`,`number`, `state`, `service_name`, `service_product`, `service_version`, `service_extra`, `service_ostype`, `script_info`)
            VALUES (?,?,?,?,?,?,?,?,?,?)',
            undef,
            $this->{scanId},
            $this->{protocol},
            $this->{portNumber},
            $this->{state},
            $this->{serviceName},
            $this->{product},
            $this->{productVersion},
            $this->{serviceExtra},
            $this->{ostype},
            $this->{scriptInfo}
        );
    }
}

1;
