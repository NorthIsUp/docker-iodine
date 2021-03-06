#!/bin/sh

if [ -z ${IODINE_HOST} ]; then echo "Error: The external hostname must be specified in the IODINE_HOST enviroment variable"; exit 1; fi
if [ -z ${IODINE_PASS} ]; then echo "Error: The Iodine password must be specified in the IODINE_PASS enviroment variable"; exit 1; fi
if [ -z ${IPTABLES} ]; then IPTABLES="iptables -t filter -A FORWARD -i dns0 -o eth0 -j ACCEPT" && echo "WARN: Using standard IP tables rules - all traffic will be forwarded."; fi
if [ ! -e '/dev/net/tun' ]; then echo "Error: You must run this Dockerfile with --cap-add=NET_ADMIN"; exit 1; fi

IODINE_IP=${IODINE_IP:-"10.42.16.1/24"}
EXT_IP=$(wget -qO- http://ipinfo.io/ip)

iptables -P FORWARD DROP
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t filter -A FORWARD -i eth0 -o dns0 -m state --state RELATED,ESTABLISHED -j ACCEPT

$IPTABLES

iodined -c -f -P $IODINE_PASS -n $EXT_IP $IODINE_IP $IODINE_HOST
