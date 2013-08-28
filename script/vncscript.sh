#!/bin/bash
r=$(echo $row | sed 's/^\["//g' | sed 's/"\]$//g')
ip=$(echo $r | awk -F':' '{print $1}')
port=$(echo $r | awk -F':' '{print $2}')
image=/tmp/$ip-$port.jpg
echo $r > /tmp/test
vncsnapshot -allowblank -quiet -passwd /dev/null $r $image
if [[ $? == 0 ]]
then
    (echo "VNC $ip $port" ; uuencode $image $ip-$port.jpg)|mail -s 'VNC Open' $1
    rm $image
fi
