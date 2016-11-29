#!/usr/bin/python
import json
import subprocess

returnvalue = { "data" : [] }
p = subprocess.Popen('/usr/lib/zabbix-check/bin/zabbix-check-disk-performance-discover', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for hdd in p.stdout.readlines():
    returnvalue["data"].append({ "{#DEVICENAME}" : hdd.strip() })
print json.dumps(returnvalue)

