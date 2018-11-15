# EPIC-VPN-Client
Opto 22 *groov* EPIC SoftEther Virtual Private Network (VPN) client shell project.

---

## vpn-client.sh $1
Main control script, run as root and provide exactly one parameter:
* 2 = run client setup
* 1 = start VPN connection
* 0 = stop VPN connection

For example, `sudo ./vpn-client.sh 2` will run the initial VPN client setup commands.<br>
Before executing the script you must modify the server details at the top of the file:
```
NAME=NULL			connection name
HOST='127.0.0.1'		server hostname / IP address
PORT='5555'			VPN server port
VHUB=vpn			VPN virtual hub name
USER=flynn			VPN login account username
PASS=secret			VPN login account password
```

## undo.sh $1
Programmatically undoes everything that `vpn-client.sh` could have changed, with the **connection name** given as the parameter `$1`.<br>
For example, `sudo ./undo.sh home` to remove the VPN connection named "home" plus its associated network controller and firewall settings.

## show-empty.sh
Run `sudo ./show-empty.sh` to programmatically show there is no VPN set up, no non-default network interfaces, and no firewall rules.

## runcmd.sh $1
Puts the given command `$1` through vpncmd for the localhost client.<br>
This just lets you use `sudo ./runcmd.sh $1` instead of `sudo /usr/bin/vpncmd localhost /CLIENT /CMD $1` for manual commands.<br>
For example, `sudo ./runcmd.sh accountlist` to list current VPN settings and their connection status.

---

**written by:** *Terry Orchard, Opto 22*
