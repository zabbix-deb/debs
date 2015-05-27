#!/usr/bin/python
import subprocess
import sys
import re

smart_key_re = re.compile(r'^\s*\d+ (\w+)\s+0x[a-f0-9]+\s+(\d+).*\s+\-\s+(\d+).*$')


if len(sys.argv) <= 2:
    print ''
    print 'How to use the Script:'
    print '     Example for RAW_VALUE Data:', sys.argv[0], 'sda Power_On_Hours'
    print '     Example for VALUE Data:', sys.argv[0], 'sda Power_On_Hours value'
    print ''
    sys.exit(1)

hdd = sys.argv[1]
smart_key = sys.argv[2]

smart_value = 0
if len(sys.argv) == 4 and sys.argv[3] == 'value':
    smart_value = 1

output = subprocess.Popen(['sudo', 'smartctl', '-A', '/dev/{0}'.format(hdd)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(stdout, stderr) = output.communicate()

for line in stdout.split("\n"):
    match = smart_key_re.match(line)
    if match:
        if match.group(1).lower() == smart_key.lower():
            if smart_value == 1:
                print match.group(2)
            else:
                print match.group(3)
