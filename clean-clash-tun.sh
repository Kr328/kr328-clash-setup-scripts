#!/bin/bash

exec 1> /dev/null
exec 2> /dev/null

PROXY_BYPASS_USER="proxy"
PROXY_BYPASS_CGROUP="0x16200000"
PROXY_FWMARK="0x162"
PROXY_ROUTE_TABLE="0x162"
PROXY_DNS_PORT="1053"
PROXY_FORCE_NETADDR="198.18.0.0/16"
PROXY_TUN_DEVICE_NAME="clash0"
PROXY_TUN_ADDRESS="172.31.255.253/30"

ip link set dev "$PROXY_TUN_DEVICE_NAME" down
ip tuntap del "$PROXY_TUN_DEVICE_NAME" mode tun

ip route del default dev "$PROXY_TUN_DEVICE_NAME" table "$PROXY_ROUTE_TABLE"
ip rule del fwmark "$PROXY_FWMARK" lookup "$PROXY_ROUTE_TABLE"

iptables -t mangle -D OUTPUT -j CLASH
iptables -t mangle -D PREROUTING -m set ! --match-set localnetwork dst -j MARK --set-mark "$PROXY_FWMARK"

iptables -t nat -D OUTPUT -p udp --dport 53 -j CLASH_DNS
iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports "$PROXY_DNS_PORT"

iptables -t mangle -F CLASH
iptables -t mangle -X CLASH

iptables -t nat -F CLASH_DNS
iptables -t nat -X CLASH_DNS

ipset destroy localnetwork

exit 0
