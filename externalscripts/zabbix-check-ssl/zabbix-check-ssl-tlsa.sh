#!/bin/bash
#zabbix-check-ssl-tlsa (c) by Christoph Hueffelmann <chr@istoph.de> 2016
#Lizens: GPLv3
#RFC: https://tools.ietf.org/html/rfc6698

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

dns=$(dig _${port}._tcp.${domain} IN TLSA +short)
if [ "$dns" = "" ]; then
    #echo "no tlsa record set";
    echo 1
    exit 1
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

    type=$(echo $dns | awk '{print $3}')
    if [ "$type" -eq "1" ]; then #sha256
        sslhash=$(openssl x509 -in $tmp -outform DER | openssl sha256 | awk '{print $2}')
    elif [ "$type" -eq "1" ] ; then #sha512
        sslhash=$(openssl x509 -in $tmp -outform DER | openssl sha512 | awk '{print $2}')
    else
        #echo "hash algorithm not implemented"
        exit 2
    fi

    dnshash=$(echo $dns|cut -d' ' -f4- | sed 's/ //g')

    if [ "${dnshash,,}" = "${sslhash,,}" ]; then
        echo 0
        exit 0
    fi

    echo 3
    exit 3
fi

echo 4
exit 4