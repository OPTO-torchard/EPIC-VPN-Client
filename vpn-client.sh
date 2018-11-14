#!/bin/bash
# Set the following variables:
NAME=NULL
HOST='127.0.0.1'
PORT='5555'
VHUB=vpn
USER=flynn
PASS=secret
TYPE=standard
CONN=tun0

# For internal use:
NICN=epic
INTF="$VHUB"_"$NICN"
SERV="$HOST":"$PORT"
# Check to make sure the server settings have been added:
if [ $NAME = "NULL" ]
then
	echo Update server settings in script before executing.
	echo Stopping script . . .
	exit 1
fi
# Check to make sure an instruction is provided:
if [ $# != 1 ]
then
	echo Please enter exactly one command parameter.
	echo Stopping script . . .
	exit 1
fi
# INTERNAL FUNCTIONS:
function vpncmd() {
	sudo /usr/bin/vpncmd localhost /CLIENT /CMD $@
}
function vpnclient() {
	sudo /etc/init.d/vpnclient $@
}
function renameInterface () {
	echo Renaming $INTF to $CONN . . .
        sleep 1
	if [ -e "/sys/class/net/$INTF/operstate" ]
	then
		echo $INTF exists, renaming now.
        	ip link set $INTF down
        	ip link set $INTF name $CONN
        	ip link set $CONN up
        	ifconfig
        	sleep 1
	else
		echo $INTF Was not created, exiting script . . .
		exit 1
	fi
}
# CONTROL FUNCTIONS:
function clientSetup {
	# Start the client and create a network interface controller:
	vpnclient start
	vpncmd NicCreate $NICN
	# Rename the network interface so it does not have an underscore:
	ifconfig
	renameInterface
	# Create the account for the new VPN Server and provide a password:
	vpncmd accountcreate $NAME /SERVER:$SERV /HUB:$VHUB /USERNAME:$USER /NICNAME:$NICN
	vpncmd accountpasswordset $NAME /PASSWORD:$PASS /TYPE:$TYPE
	sleep 10
	# Setup is complete, stop the VPN client.
	vpncmd accountlist
	ifconfig
	vpnclient stop
}
function clientConnect {
	vpnclient start
	vpncmd niclist
	ifconfig
	vpncmd accountconnect $NAME
	echo . . . accountconnect . . .
	renameInterface
	echo . . . accountlist . . .
	vpncmd accountlist
	sudo dhclient-real $CONN
	sleep 1
	ifconfig
	ufw allow in on $CONN from any to any
}
function clientDisconnect {
	vpncmd accountdisconnect $NAME
	sleep 3
	vpnclient stop
	ufw delete allow in on $CONN from any to any
}

case $1 in
        0)
                echo Disconnecting from server . . .
		clientDisconnect
                ;;
        1)
                echo Connecting to server . . .
		clientConnect
                ;;
        2)
                echo Running client setup . . .
		clientSetup
                ;;
        *)
                echo groov EPIC VPN client script help
                echo Before executing please modify the server credentials.
                echo This script requires exactly one parameter:
                echo $'\t'2 = run client setup
                echo $'\t'1 = start VPN connection
                echo $'\t'0 = stop VPN connection
                ;;
esac
