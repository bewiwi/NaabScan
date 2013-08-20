#Config file to cp in config.pl
#MysqlConf
$dbHost = 'localhost';
$dbUser = 'naabscan';
$dbBase = 'naabscan';
$dbPwd = 'naabscan';

#Xml Folder
$xmlFolder = './xml/wait/';
$doneFolder = './xml/done/';

#Autoscan, Nmap arguments
$nmapArg = '-A -PN';
$nmapThread = 10;

#SQL
#placeholder :
#<scanid> = id du scan

$sqlAll = 'SELECT 1';
$sqlVNC = "SELECT CONCAT( h.ip,':',p.number-5900) 
    FROM host h, scan s, port p
    WHERE 1 =1
    AND s.id = <scanid>
    AND h.id = s.host_id
    AND s.id = p.scan_id
    AND UPPER( p.service_name ) LIKE  '%VNC%'
    AND UPPER( p.service_name ) NOT LIKE  '%HTTP%'";

#Script
#Env variable $scan, $row (json) and $ip

#Triggers
$mail='mon@mail.fr monmail2@test.fr';

$triggers = {
    'all' => {
        sql => $sqlAll,
        script => 'echo "$scan" | mail -s Test "'.$mail.'"'
    },
    'vnc' => {
        sql => $sqlVNC,
        script => './script/vncscript.sh "'.$mail.'"'
    }
};
