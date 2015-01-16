#!/usr/bin/python
import subprocess
import sys
import re

smart_key_re = re.compile(r'^\s*\d+ (\w+)\s+0x[a-f0-9]+\s+(\d+).*\s+\-\s+(\d+).*$')

hdd = sys.argv[1]
smart_key = sys.argv[2]

if len(sys.argv) == 4:
    smart_value = 1
else:
    smart_value = 0

output = subprocess.check_output(["sudo", "smartctl", "-A", "/dev/{0}".format(hdd)])
for line in output.split("\n"):
    match = smart_key_re.match(line)
    if match:
        if match.group(1).lower() == smart_key.lower():
            if smart_value == 1:
                print match.group(2)
            else:
                print match.group(3)
