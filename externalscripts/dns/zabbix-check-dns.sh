#!/bin/bash

domain=$1
if [ "$domain" = "" ]; then
	exit 1
fi

host -t ns $domain | awk '{print $4}' | while read l; do 

	#check mx if domain available
	host -t mx $domain $l >/dev/null 2>&1
	mx=$?
	if [ "$mx" -gt "0" ]; then
		echo "DNS SERVER $l NOT ANSWER"
	fi

	#check soa if all ns server up to date	
	soa=$(host -t soa $domain $l | tail -n1 | md5sum | awk '{print $1}')
	if [ "$soacheck" = "$soa" ] || [ "$soacheck" = "" ]; then
		soacheck=$soa
	else
		echo "DNS SOA NOT UP TO DATE"
	fi

done


#TODO: top down check

