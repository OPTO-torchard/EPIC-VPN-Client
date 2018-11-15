#!/bin/bash
if [ $# != 1 ]
then
	echo Please provide the connection name.
	echo Stopping script . . .
	exit 1
fi
function vpncmd() {
        sudo /usr/bin/vpncmd localhost /CLIENT /CMD $@
}

function vpnclient() {
        sudo /etc/init.d/vpnclient $@
}
echo Removing VPN connection settings . . .
vpnclient start
vpncmd accountdisconnect $1
vpncmd accountdelete $1
vpncmd nicdelete epic
vpnclient stop
echo Removing firewall exceptions . . .
ufw delete allow in on tun0 from any to any
echo END OF LINE
