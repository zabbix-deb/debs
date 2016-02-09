#!/usr/bin/python
import os
import json
import re

md_list = []
md_pattern = re.compile(r'^md[0-9]+$')
for name in os.listdir("/dev/"):
    match = md_pattern.match(name)
    if match:
        md_list.append(match.group(0))

returnvalue = { "data" : [] }
for md in md_list:
    returnvalue["data"].append({ "{#MD}" : md })
print json.dumps(returnvalue)
