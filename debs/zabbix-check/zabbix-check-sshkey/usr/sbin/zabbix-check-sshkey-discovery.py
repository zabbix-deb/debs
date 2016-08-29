#!/usr/bin/env python

# get start and end uid for users from /etc/adduser.conf
# also from root user
# get users homes from this range over pwd
# check if there is an .ssh/authorized_keys
# output .ssh path

import json
import pwd
import re
import os

aufile = "/etc/adduser.conf"
returnvalue = { "data" : [] }

def getUIDs(begin):
    uid_re = re.compile(r'^({0})_UID=(\d+)'.format(begin), re.MULTILINE)
    with open(aufile) as f:
        output = f.read()
    results = uid_re.findall(output)
    for result in results:
        if begin == "FIRST":
            return result[1]
        elif begin == "LAST":
            return result[1]

def main():
    uid_first = int(getUIDs("FIRST"))
    uid_last = int(getUIDs("LAST"))
    homes = ['/root/.ssh']

    for uid in range(uid_first, uid_last+1):
        try:
            homes.append(pwd.getpwuid(uid).pw_dir + "/.ssh")
        except:
            continue

    for path in homes:
        if os.path.exists(path + "/authorized_keys"):
            returnvalue["data"].append({ "{#SSHAPATH}" : path+"/authorized_keys" })
    print json.dumps(returnvalue)

if __name__ == "__main__":
    main()
