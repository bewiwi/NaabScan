package NAABSCAN::NMAP;
use Data::Dumper;


sub new
{
    my (
        $classe,
        $ip,
        $nmapArg,
        $xmlFolder
    )=@_;

    my $this = {
        "ip" => $ip,
        "nmapArg" => $nmapArg,
        "xmlFolder" => $xmlFolder
    };
    bless( $this, $classe );
    return $this;

}


sub scan
{
    my $this = shift ;
    my $cmd = 'nmap '.$this->{nmapArg}.' -oX '.$this->{xmlFolder}.'/'.$this->{ip}.'-autoscan.xml '.$this->{ip};
    my $ret = `$cmd`;
    if ( $? != 0 )
    {
        print "Nmap ERROR :\n";
        print $ret;
        return 0;
    } else {
        return 1;
    }
}

1;
