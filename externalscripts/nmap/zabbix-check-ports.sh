#!/bin/bash

# Copyright (C) 2005 Mark Stingley
# mark AT altsec.info

# Copyright (C) 2015 Christoph Hüffelmann
# christoph-hueffelmann@cubos-internet.de

#TODO: übergabe ablaufzeit override inital ckeck

IP=$1

if [ ! "$IP" ]; then

   echo "No IP address supplied"
   exit 255

fi

if [ ! -x "/usr/bin/nmap" ]; then

   echo "apt-get install nmap"
   echo 255

fi

BASEDIR=/var/cache/zabbix/check-ports 
SCANDIR=$BASEDIR/scans
[ ! -d $SCANDIR ] && mkdir -p $SCANDIR

FILEDIR=$BASEDIR/files
[ ! -d $FILEDIR ] && mkdir $FILEDIR

CHANGED=0
INITIAL=0

if [ ! -f $SCANDIR/$IP.base ]; then

   touch $SCANDIR/$IP.base
   INITIAL=1

fi

nmap -T5 -sT -P0 $IP | grep -w open | sort | sed -e "s/ \\+/ /g" > $SCANDIR/$IP

if [ $INITIAL -eq 1 ]; then

   cat $SCANDIR/$IP > $SCANDIR/$IP.base
   echo "Initial scan"
   exit 0

fi

SCANTIME=`/bin/date +%Y%m%d-%H%M`
DIFF=`/usr/bin/comm -23 $SCANDIR/$IP $SCANDIR/$IP.base`
if [ "$DIFF" ]; then

   DIFFSTR=`echo "$DIFF" | awk '{print $1}' | paste -s -d " " -`

   echo "Scan $SCANTIME: NEW $DIFFSTR"
   exit 1

else

   echo "$SCANTIME: no change"
   exit 0

fi

