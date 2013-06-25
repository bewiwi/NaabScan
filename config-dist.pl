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


#SQL
#placeholder :
#<scanid> = id du scan
#
#All request
$sqlAll = 'SELECT 1';
#Check VNC
$sqlVNC = "SELECT p.number
FROM host h,scan s , port p
Where s.id = <scanid>
AND  h.id = s.host_id
AND s.id = p.scan_id
AND UPPER(p.service_name) like '%VNC%'";


#Script
#send all report with mail
$scriptMail = 'echo $row | mail -s Test mail@mail.fr';
#send ip and port with mail
$scriptVnc = 'echo $ip $row | mail -s VNC mail@mail.fr';


#Triggers
$triggers = {
    'all' => {
        sql => $sqlAll,
        script => $scriptMail

    },
    'vnc' => {
        sql => $sqlVNC,
        script => $scriptVnc
    }
};
