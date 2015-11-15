#!/bin/bash
# Copyright (C) 2015 Christoph Hüffelmann
# christoph-hueffelmann@cubos-internet.de

host=$1
cash=/var/cash/zabbix/zabbix-check-nmap

if [ ! "$host" ]; then

   echo "No IP address supplied"
   exit 1

fi

if [ ! -x "/usr/bin/nmap" ]; then

   echo "apt-get install nmap"
   exit 2

fi

if [ ! -d $cash ]; then
	echo "## TODO: "
	echo sudo mkdir -p $cash
	echo sudo chown zabbix: $cash
	exit 3
fi

function scann() {

tmp=$(mktemp)
nmap -T5 -sT -P0 $host | grep -w open | awk '{print $1}' > $tmp
if [ -e $cash/$host  ]; then
	diff -u $cash/$host $tmp | sed 1,3D | grep ^+ | awk -F '+' '{print $2}' | sed -e "s/ \\+/ /g" | paste -s -d " " $cash/$host.diff
	rm $tmp
else
	echo -n "FIRST CHECK $host"
	mv $tmp $cash/$host
fi

}

scann &
if [ -s $cash/$host.diff ]; then
	cat $cash/$host.diff
fi
exit 0
