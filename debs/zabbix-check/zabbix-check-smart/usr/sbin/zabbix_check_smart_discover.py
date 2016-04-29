#!/usr/bin/python
import os
import json
import re

hdd_list = []
hdd_pattern = re.compile(r'^[hs]{1}d[a-z]{1}$')
for name in os.listdir("/dev/"):
    match = hdd_pattern.match(name)
    if match:
        hdd_list.append(match.group(0))

returnvalue = { "data" : [] }
for hdd in hdd_list:
    returnvalue["data"].append({ "{#HDD}" : hdd })
print json.dumps(returnvalue)
