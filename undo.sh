#!/bin/bash

function vpncmd() {
        sudo /usr/bin/vpncmd localhost /CLIENT /CMD $@
}

function vpnclient() {
        sudo /etc/init.d/vpnclient $@
}

vpnclient start
vpncmd accountdisconnect home
vpncmd accountdelete home
vpncmd nicdelete epic
vpnclient stop

ufw delete allow in on tun0 from any to any
