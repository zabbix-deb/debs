#!/bin/bash

domain=$1
if [ "$domain" = "" ]; then
	exit 1
fi

ns=$(host -t ns $domain | awk '{print $4}'|tail -n1)

DIGOPTS="+multiline +bufsize=4096 +time=3 +tries=2 +retry=0 +nosearch +ignore +fail +nocmd +nostats +nottlid"
d=$(dig ${DIGOPTS} +nomultiline +noadd +noauth +cdflag +dnssec @$ns $domain soa | grep RRSIG | awk '{print $8}')

if [ "$d" != "" ]; then
	let sec=$(date -d "${d:0:4}/${d:4:2}/${d:6:2} ${d:8:2}:${d:10:2}:${d:12:2}" "+%s")-$(date "+%s")
	echo $sec
fi
exit 0
