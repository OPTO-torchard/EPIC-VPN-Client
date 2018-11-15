# EPIC-VPN-Client
Opto 22 groov EPIC SoftEther virtual private network client project

---

## vpn-client.sh $1
Main control script, requires exactly one parameter:
* 2 = run client setup
* 1 = start VPN connection
* 0 = stop VPN connection

Before executing script you must modify the server credentials:
```
NAME=NULL			connection name
HOST='127.0.0.1'		server hostname / IP address
PORT='5555'			VPN server port
VHUB=vpn			VPN virtual hub name
USER=flynn			VPN login account username
PASS=secret			VPN login account password
```

## undo.sh $1
Will remove the connection created with the name given as the parameter `$1`<br>
For example, `sudo ./undo.sh home` to remove VPN connection named "home".

## show-empty.sh
Run `sudo ./show-empty.sh` to automatically show that there is no VPN connection or network interface controller set up.

## runcmd.sh $1
Puts the given command `$1` through vpncmd for the localhost client.<br>
This just means you can type `./runcmd.sh CMD` instead of `sudo /usr/bin/vpncmd localhost /CLIENT /CMD CMD`.

### Terry Orchard, Opto 22 - Temecula, CA
