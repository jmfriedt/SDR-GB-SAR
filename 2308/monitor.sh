#!/bin/sh

IFACE=wlp1s0u1u2
CHANNEL=100

### check for command line arguments
if [[ $# -eq 1 ]]
then
 CHANNEL=$1
fi

echo "setting interface >>${IFACE}<< to monitor channel >>${CHANNEL}<<"

# sudo service network-manager stop
ifconfig ${IFACE} down
iwconfig ${IFACE} mode monitor 
ifconfig ${IFACE} up
iwconfig ${IFACE} channel ${CHANNEL} 
