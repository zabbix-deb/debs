#!/bin/bash

domain=$1
port=$2
t=2

if [ "$domain" = "" ]; then
        echo "$0 domain.tld [port]"
        exit 1
fi
if [ "$port" = "" ]; then
        port="443"
fi

tmp=$(mktemp)
trap "rm -f $tmp" 0 1 2 5 15
case $port in
    21)
        #FTP
        echo | timeout $t openssl s_client -connect $domain:$port -starttls ftp 2>/dev/null > $tmp
        ;;        
    25|465|587)
        #SMTP
        echo | timeout $t openssl s_client -connect $domain:$port -starttls smtp 2>/dev/null > $tmp
        ;;
    143|993)
        #IMAP
        echo | timeout $t openssl s_client -connect $domain:$port -starttls imap 2>/dev/null > $tmp
        ;;
    110|995)
        #POP3
        echo | timeout $t openssl s_client -connect $domain:$port -starttls pop3 2>/dev/null > $tmp
        ;;
    *)    
        #HTTPS SNI
        echo | timeout $t openssl s_client -servername $domain -connect $domain:$port 2>/dev/null > $tmp
        ;;
esac

if ! grep -q "CERTIFICATE" $tmp; then
    echo | timeout $t openssl s_client -connect $domain:$port 2>/dev/null > $tmp
fi

if grep -q "CERTIFICATE" $tmp; then
        d=$(cat $tmp | openssl x509 -noout -dates | grep notA | awk -F'=' '{print$2}')

        let t=$(date -d "$d" "+%s")-$(date "+%s")
        echo $t
        exit 0
fi
echo 0
exit 1

