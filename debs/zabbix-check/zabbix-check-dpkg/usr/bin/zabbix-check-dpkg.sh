#!/bin/bash
export LANG=C

share="/usr/share/zabbix/dpkg"
mkdir -p $share
echo 0 | tee $share/error.log | tee $share/updates.log > $share/security.log

function checkrun() {
	err=0
	for i in {0..5}; do 
		apt-get check >/dev/null 2>&1
		err=$?
		if [ "$err" -eq "0" ]; then
			return 0
		fi
		sleep 360
	done
	echo $err > $share/error.log
	exit 1
}

#check runig updates
checkrun

#update database
apt-get update >/dev/null 2>&1 || (echo $? > $share/error.log; exit 1)

#check updates
tmp=$(mktemp)
trap "rm -f $tmp" 0 1 2 5 15
apt-get upgrade -s 2>/dev/null > $tmp || (echo $? > $share/error.log; exit 2)
grep -vi security $tmp | grep ^Inst | wc -l > $share/updates.log
grep -i security $tmp | grep ^Inst | wc -l > $share/security.log

exit 0
