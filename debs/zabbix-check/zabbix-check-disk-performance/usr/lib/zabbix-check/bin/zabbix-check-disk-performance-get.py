#!/usr/bin/python

import sys
import os

def getRealDevName(dev):
    devpath = "/dev/disk/by-id/dm-name-{0}".format(dev)
    if os.path.exists(devpath):
        return os.path.realpath(devpath).split('/')[2]
    else:
        return dev

opt = ['read.ops', 'read.merged', 'read.sectors', 'read.ms',
    'write.ops', 'write.merged', 'write.sectors', 'write.ms',
    'io.active', 'io.ms', 'weight.io.ms']
arg = sys.argv[1]
device = getRealDevName(sys.argv[2])

try:
    with open('/sys/class/block/{0}/stat'.format(device)) as f:
        stats = f.read().split()
except IOError as e:
    print "An error occured: {0}".format(e)
    sys.exit(1)

opt_per_stat = dict(zip(opt, stats))

try:
    print opt_per_stat[arg]
except KeyError as e:
    print "Wrong Key: {0}".format(e)
    sys.exit(1)
