#!/usr/bin/python

import sys
import json

data = []
for ln in sys.stdin.readlines():
    ln = ln.strip()
    data.append({'{#LXCNAME}':ln})

res = {"data": data}

print json.dumps(res)
