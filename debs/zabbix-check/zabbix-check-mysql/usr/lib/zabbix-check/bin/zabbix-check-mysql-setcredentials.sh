#!/bin/bash
# This script add a mysql user: zabbixcheck or update his password

if [ -e /var/lib/zabbix/.my.cnf ]; then
	echo "mysql credentials will be override"
fi

if ! mysql <<< "SELECT * FROM information_schema.tables;" >/dev/null; then
	echo "can not connect to mysql without credentials"
	exit 0;
fi

pw=$(date +%s | sha256sum | base64 | head -c 26)

mkdir -p /var/lib/zabbix
echo "[client]
user=zabbixcheck
password=$pw
" > /var/lib/zabbix/.my.cnf

chown -R zabbix: /var/lib/zabbix

#TODO: prüfen ob user exist dann pw updaten
mysql <<<"DROP USER 'zabbixcheck'@'localhost';" 2>/dev/null || true
mysql <<<"CREATE USER 'zabbixcheck'@'localhost' IDENTIFIED BY '$pw'; FLUSH PRIVILEGES;"
exit 0
