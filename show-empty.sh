#!/bin/bash
function vpncmd() {
	sudo /usr/bin/vpncmd localhost /CLIENT /CMD $@
}
function vpnclient() {
	sudo /etc/init.d/vpnclient $@
}
echo Showing that no VPN is currently set up . . . $'\n'
vpnclient start
echo . . . No VPN server settings:
vpncmd accountlist
echo . . . No Network Interface Controller (NIC):
vpncmd niclist
echo . . . No non-default network interfaces:
ifconfig
echo . . . No firewall exceptions:
ufw status
vpnclient stop
echo END OF LINE
