#!/bin/bash
# Set the following variables:
NAME=NULL
HOST='127.0.0.1'
PORT='5555'
VHUB=vpn
USER=flynn
PASS=secret

# Password $TYPE is 'standard' or 'radius':
TYPE=standard
# Virtual network connection interface name:
CONN=tun0
# For internal use:
NICN=epic
INTF="$VHUB"_"$NICN"
SERV="$HOST":"$PORT"
# Check to make sure the server settings have been added:
if [ $NAME = "NULL" ]
then
	echo Modify server settings in script before executing.
	echo Stopping script . . .
	exit 1
fi
# Check to make sure an instruction is provided:
if [ $# != 1 ]
then
	echo Please provide exactly one command parameter.
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
	echo Checking $INTF . . .
        sleep 1
	if [ -e "/sys/class/net/$INTF/operstate" ]
	then
		echo . . . $INTF exists, renaming now.
        	ip link set $INTF down
        	ip link set $INTF name $CONN
        	ip link set $CONN up
        	sleep 1
	else
		echo $INTF Was not created.
		echo Stopping script . . .
		exit 1
	fi
	sleep 1
	if [ -e "/sys/class/net/$CONN/operstate" ]
	then
		echo Interface succesfully renamed to $CONN.
	else
		echo Interface rename failed.
		echo Stopping script . . .
		exit 1
	fi
}
# CONTROL FUNCTIONS:
function clientSetup {
	# Start the client and create a network interface controller:
	vpnclient start
	sleep 1
	vpncmd NicCreate $NICN
	# Rename the network interface so it does not have an underscore:
	renameInterface
	# Create the account for the new VPN server and provide a password:
	vpncmd accountcreate $NAME /SERVER:$SERV /HUB:$VHUB /USERNAME:$USER /NICNAME:$NICN
	vpncmd accountpasswordset $NAME /PASSWORD:$PASS /TYPE:$TYPE
	# Setup is complete, double check the settings and then stop the VPN client.
	vpncmd accountlist
	vpncmd niclist
	vpnclient stop
}
function clientConnect {
	vpnclient start
	vpncmd accountlist
	vpncmd niclist
	# Connect to VPN server and fix network interface:
	vpncmd accountconnect $NAME
	renameInterface
	vpncmd accountlist
	# Get an IP address and make necessary firewall exceptions:
	sudo dhclient-real $CONN
	sleep 1
	ufw allow in on $CONN from any to any
	ufw status
	# Return the IP address given by the VPN server:
	ifconfig $CONN | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'
}
function clientDisconnect {
	vpncmd accountdisconnect $NAME
	sleep 3
	vpnclient stop
	ufw delete allow in on $CONN from any to any
	ufw status
}
# MAIN CONTROL LOGIC:
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
        *)	# -help
                echo groov EPIC VPN client script help
                echo Before executing please modify the server credentials.
                echo This script requires exactly one parameter:
                echo $'\t'2 = run client setup
                echo $'\t'1 = start VPN connection
                echo $'\t'0 = stop VPN connection
                ;;
esac
