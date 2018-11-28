#!/bin/bash
# Set the following variables:
SERVER_PASS=veryverysecret
HUB_PASS=secret

USER_LIST=(user1 user2 user3 user4)
PASS_LIST=(pass1 pass2 pass3 pass4)

PSK=EasyPreSharedKey

# Internal variables:
# Leave hub name as default, consider chaning HUB_PASS.
HUB_NAME=vpn
VPN_VERSION=4.28-9669-beta-2018.09.11
VPN_TAR=softether-vpnserver-v$VPN_VERSION-linux-x64-64bit.tar.gz
CWD=$(pwd)
# Check to make sure the server settings have been added:
if [ $SERVER_PASS = "verysecret" ]
then
	echo Modify server credentials in script before executing.
	echo Stopping script . . .
	exit 1
fi
# Check to make sure every user hass a password:
if [ ${#USER_LIST[*]} != ${#PASS_LIST[*]} ]
then
	echo Number of users does not match number of passwords.
	echo Please edit the USER_LIST and PASS_LIST.
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

function installServer {
	wget http://www.softether-download.com/files/softether/v$VPN_VERSION-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/$VPN_TAR
	tar -xf $VPN_TAR
	rm $VPN_TAR
	cd $CWD/vpnserver
	
	yes 1 | sudo make

	sudo chmod 644 *
	sudo chmod 755 vpnserver vpncmd
	
	sudo ln -s $(pwd)/vpncmd /usr/sbin/vpncmd
	cd $CWD
	sudo mv vpnserver /usr/local/
}
function configureServer {
	function vpncmd() {
		sudo /usr/local/vpnserver/vpncmd localhost /SERVER /ADMINHUB:$HUB_NAME /PASSWORD:$SERVER_PASS /CMD $@
	}
	# Start server runtime:
	sudo /usr/local/vpnserver/vpnserver start
	sleep 1
	# Set the server password:
	sudo /usr/local/vpnserver/vpncmd localhost /SERVER /CMD ServerPasswordSet $SERVER_PASS
	# Create VPN hub:
	sudo /usr/local/vpnserver/vpncmd localhost /SERVER /PASSWORD:$SERVER_PASS /CMD HubCreate $HUB_NAME /PASSWORD:$HUB_PASS
	# Enable Virtual Network Address Translation:
	vpncmd SecureNatEnable
	# Add default users:
	for i in $(seq 0 $((${#USER_LIST[*]}-1)))
	do
		echo Adding user $i
		vpncmd UserCreate ${USER_LIST[i]} /GROUP:none /REALNAME:none /NOTE:"User created via install script."
		vpncmd UserPasswordSet ${USER_LIST[i]} /PASSWORD:${PASS_LIST[i]}
	done
	# Set IP protocols:
	vpncmd IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:yes /PSK:$PSK /DEFAULTHUB:$HUB_NAME
}
# MAIN CONTROL LOGIC:
case $1 in
        0)
            echo Disconnecting from server . . .
			sudo /usr/local/vpnserver/vpnserver stop
            ;;
        1)
            echo Connecting to server . . .
			sudo /usr/local/vpnserver/vpnserver start
            ;;
        2)
            echo Running server installation . . .
			installServer
			echo Configuring server . . .
			configureServer
			echo Server set up and running.
            ;;
        *)	# -help
            echo -- Basic SoftEther VPN server script help --
            echo Before executing you must modify the server credentials.
            echo This script requires sudo and exactly one parameter:
            echo $'\t'2 = run server setup
            echo $'\t'1 = start VPN server
            echo $'\t'0 = stop VPN server
            ;;
esac
echo END OF LINE
