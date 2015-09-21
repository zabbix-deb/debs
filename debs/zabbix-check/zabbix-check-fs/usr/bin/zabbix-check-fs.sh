#!/bin/bash

tmp=$(mktemp)
trap "rm $tmp" 0
#TODO: check other fs
LANG=C dumpe2fs -h $(cat /proc/mounts | grep ^/ | grep " / " | awk '{print $1}') > $tmp 2>/dev/null

#Mount count:              1
#Maximum mount count:      24
#Last checked:             Tue Aug 11 02:02:14 2015
#Check interval:           15552000 (6 months)
#Next check after:         Sun Feb  7 01:02:14 2016

fsck=0
if grep 'Next check after' $tmp >/dev/null; then
	#echo $(grep 'Next check after' $tmp | awk -F ':' '{print $2":"$3":"$4}')
	nca=$(date -d "$(grep 'Next check after' $tmp | awk -F ':' '{print $2":"$3":"$4}')" +%s)
	fsck=$(( $nca - $(date +%s) ))
fi

#if enough time then check mound count to
if [ "$fsck" -gt "0" ]; then
	mc=$(grep 'Mount count' $tmp | awk -F ':' '{print $2}')
	mmc=$(grep 'Maximum mount count' $tmp | awk -F ':' '{print $2}')
	##TODO CHECK or and:
	if [ "$fsck" -eq "0" ] || [ "$mmc" -ge "0" ] && [ "$mmc" -le "$mc" ]; then
		echo "$(( $mmc - $mc ))"
		exit 0
	fi
fi

echo $fsck
exit 0
