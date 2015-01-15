#! /bin/sh
################################################################################
# Zabbix extensions (C) 2011-* Joseph Bueno <zabbixextensions@aperto.fr>
# Published under GNU General Public License version 2 or later.
# See LICENSE.txt
#-------------------------------------------------------------------------------
# Description:
#  Check host IP against a list of DNS blacklists
#
# Usage:
#   zext_dnsbl_check.sh <hostname_or_IP> <zabbix_hostname> <IP>
#
#  <hostname_or_IP> : ignored
#  <zabbix_hostname>: Zabbix hostname
#  <IP>             : IP address to check
#
# Zabbix item:
#  Type               : external check
#  Key                : zext_dnsbl_check.sh[{HOSTNAME} {IPADDRESS}]
#  Type of information: Numeric (unsigned)
#
# Returned value:
#  1 : dummy value
#  checks are run in background in order to avoid zabbix timeout limit.
#  real values are sent to Zabbix with zabbix_sender command.
#
# Additional items are collected and sent to Zabbix
# with zabbix_sender:
#
#  key                  : Type           : Data type: Description
# ----------+----------------+-----------------+----------------------------
#  zext_dnsbl_status    : Zabbix trapper : unsigned : number of DNS where IP
#                                                   : is blacklisted
#  zext_dnsbl_blacklists: Zabbix trapper : text     : blacklists
#  zext_dnsbl_details   : Zabbix trapper : text     : blacklist details
#  
################################################################################
# DNS RBL from : http://www.dnsbl.info/dnsbl-list.php
RBLDNS=/etc/zabbix/externalscripts/zext_dnsbl.txt
DEBUG=0
if [ "$DEBUG" -gt 0 ]
then
    exec 2>>/tmp/zext_dnsbl_check.log
    set -x
fi
shift
host=$1
ip=$2
rev_ip=`echo $ip | sed -r 's/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/\4.\3.\2.\1/'`
nohup sh -c "
    {
	result=0
	for dnsbl in \`cat $RBLDNS\`
	do
	    if host -W 1 -t a $rev_ip.\$dnsbl >/dev/null 2>&1
	    then
		echo $host zext_dnsbl_blacklists $ip blacklisted on \$dnsbl
		host -t txt $rev_ip.\$dnsbl | sed \"s/^/$host zext_dnsbl_details /\"
		result=\`expr \$result + 1\`
	    fi
	done
	echo $host zext_dnsbl_status \$result
    } | zabbix_sender -z 127.0.0.1 -r -i -
" > /dev/null 2>&1 &
echo 1
exit 0
