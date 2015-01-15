#!/bin/bash
export LANG=C

share="/usr/share/zabbix/dpkg"
mkdir -p $share
echo 0 | tee $share/error.log | tee $share/updates.log > $share/security.log

tmp=$(mktemp)
trap "rm -f $tmp" 0 1 2 5 15

#check runig updates
apt-get check >/dev/null || sleep 360
#update database
apt-get update >/dev/null || (echo $? > $share/error.log; exit 1)
#check updates
apt-get upgrade -s 2>/dev/null > $tmp || (echo $? > $share/error.log; exit 2)
grep -vi security $tmp | grep ^Inst | wc -l > $share/updates.log
grep -i security $tmp | grep ^Inst | wc -l > $share/security.log
exit 0
