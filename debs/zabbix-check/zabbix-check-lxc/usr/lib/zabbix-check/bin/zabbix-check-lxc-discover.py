#!/usr/bin/python

import json
import subprocess
import re

output = subprocess.Popen(['sudo', 'lxc-ls'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(stdout, stderr) = output.communicate()

stdout = re.findall(r'(\S+)', stdout)

returnvalue = { "data" : [] }
for container in stdout:
    returnvalue["data"].append({ "{#LXC}" : container })
print json.dumps(returnvalue)
