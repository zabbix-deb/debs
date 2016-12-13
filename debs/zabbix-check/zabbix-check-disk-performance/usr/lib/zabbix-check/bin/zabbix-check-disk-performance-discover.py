#!/usr/bin/python

import json
import os
import re

disk_id_path = "/dev/disk/by-id/"
dev_list = []
dev_re = re.compile(r'^.*(ata|scsi)+(?!.*?part).*$')
dm_re = re.compile(r'^dm-name-(.*)$')

for name in os.listdir(disk_id_path):
    dev_match = dev_re.match(name)
    dm_match = dm_re.match(name)
    if dev_match:
        real_dev = os.path.realpath(disk_id_path + dev_match.group(0)).split('/')[2]
        if real_dev != "sr0":
            dev_list.append(real_dev)
    elif dm_match:
        dev_list.append(dm_match.group(1))

returnvalue = { "data" : [] }
for dev in dev_list:
    returnvalue["data"].append({ "{#DEVICENAME}" : dev })
print json.dumps(returnvalue)
