#!/bin/bash

domain=$1
port=$2
if [ "$domain" = "" ]; then
        echo "$0 domain.tld [port]"
        exit 1
fi
if [ "$port" = "" ]; then
        port="443"
fi

tmp=$(mktemp)
echo | openssl s_client -servername $domain -connect $domain:$port 2>/dev/null > $tmp

if [ -s $tmp ]; then
        d=$(cat $tmp | openssl x509 -noout -dates | grep notA | awk -F'=' '{print$2}')

        let t=$(date -d "$d" "+%s")-$(date "+%s")
        echo $t

        exit 0
fi
echo 0
exit 1

