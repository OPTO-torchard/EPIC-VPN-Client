#!/bin/bash
echo "Executing command $@ through VPNCMD . . ."
sudo /usr/bin/vpncmd localhost /CLIENT /CMD $@
echo END OF LINE
