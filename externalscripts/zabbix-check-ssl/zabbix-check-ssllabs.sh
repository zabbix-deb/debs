#!/bin/bash
domain=$1
if [ "$domain" = "" ]; then
	exit 1
fi

tmp=$(mktemp)
#TODO: trap
wget -q -O $tmp "https://api.dev.ssllabs.com/api/fa78d5a4/analyze?host=$domain&#38;publish=On&#38;clearCache=On&#38;all=done"
sed 's/,/\n/g' $tmp | grep grade | awk -F '"' '{print $4}'
rm $tmp

exit 0
