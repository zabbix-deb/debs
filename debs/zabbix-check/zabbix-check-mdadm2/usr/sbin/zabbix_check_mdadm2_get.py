#!/usr/bin/python

import sys, re
import subprocess
import logging

logger = logging.getLogger("mdadm_check")
states = []

state_re = re.compile(r'^\s+State : ([\w ]+),*\s*([\w ]*),*\s*([\w ]*)$')
mdstat_re = re.compile(r"""(md\d{1}) : .*\n.* \[([U_]+)\]$""", re.MULTILINE)

def worstState(states):
    if len(states) == 3:
        return "recovery"
    elif len(states) == 1 or len(states) == 2:
        if "recovering" in states:
            return "recovery"
        elif "degraded" in states:
            return "degraded"
        elif "clean" in states:
            return "clean"
        elif "active" in states:
            return "active"
        else:
            return "unknown"

def getMdState(disk):
    try:
        output = subprocess.Popen(["sudo", "/sbin/mdadm", "--detail", "/dev/{0}".format(disk)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (stdout, stderr) = output.communicate()
    except subprocess.CalledProcessError, e:
        logger.error("Error Occured while running mdadm: {0}".format(e))
        return "unknown"
    except Exception, e:
        logger.error("Something really bad happened: {0}".format(e))
        return "unknown"

    for line in stdout.split("\n"):
        match = state_re.match(line)
        if not match:
            continue
        if match.group(1):
            states.append(match.group(1).strip())
        if match.group(2):
            states.append(match.group(2).strip())
        if match.group(3):
            states.append(match.group(3).strip())
        return worstState(states)
        break
    return "unknown"

def getBrokenDiskCount(disk):
    with open("/proc/mdstat") as f:
        output = f.read()
    results = mdstat_re.findall(output)
    for result in results:
        if result[0] == disk:
            return result[1].count("_")
    return -1

def main(disk, command):
    if command == "state":
        #state stuff
        print getMdState(disk)
    elif command == "mdstat":
        print getBrokenDiskCount(disk)
    else:
        print "unknown command:", command

if __name__ == "__main__":
    disk = sys.argv[1]
    command = sys.argv[2]
    main(disk, command)
