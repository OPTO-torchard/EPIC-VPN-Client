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

## show-blank.sh
Run `sudo ./show-blank.sh` to programmatically check that there is no VPN set up, no non-default network interfaces, and no firewall rules.

## runcmd.sh $1
Puts the given command `$1` through vpncmd for the localhost client.<br>
This just lets you use `sudo ./runcmd.sh $1` instead of `sudo /usr/bin/vpncmd localhost /CLIENT /CMD $1` for manual commands.<br>
For example, `sudo ./runcmd.sh accountlist` to list current VPN settings and their connection status.

---

## For use with Node-RED

To have `vpn-client.sh` executed by Node-RED using the included `flow.txt` you will need to put the script in the unsecured file area of the EPIC, use SSH to give the Node-RED user permission to run the file as root, and make it executable. After that, import the flow, make any necessary modifications to the broker and topic, and finally send `2`, `1`, or `0` as control message payloads to be appended to the command in the exec node.

1. Add a shell license through _groov_ Manage and create a shell user.
2. Open a secure shell (SSH) session with the EPIC over port 22 using [PuTTY](https://www.putty.org/) for Windows, or shell on Mac / Linux.
3. Download `vpn-client.sh` to your PC and modify the server details at the top of the file. The other files are optional.
4. Place the file in the unsecured file area so that its path is `/home/dev/unsecured/vpn-client.sh`, you can do this with groov Manage in the System Files menu.
5. In the SSH session with the EPIC, make yourself root and then modify `sudoers` so that the `dev` user can run this file as root without entering a password, and make it executable:
```
sudo su
echo "dev ALL = (root) NOPASSWD: /home/dev/unsecured/vpn-client.sh" >> /etc/sudoers
chmod +x /home/dev/unsecured/vpn-client.sh
exit
```
6. Make sure Node-RED has the package **node-red-contrib-groov**, install it through the pallet manager if you don't have it, and then import the flow from `flow.txt` through your clipboard.
7. Modify the MQTT node with the server and topic you wish to use to control the VPN client, and then deploy the flow. 

---

**written by:** *Terry Orchard, Opto 22*
