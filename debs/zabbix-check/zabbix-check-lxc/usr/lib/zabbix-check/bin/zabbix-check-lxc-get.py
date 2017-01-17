#/usr/bin/python3

import sys
import re
import subprocess
import lxc

container_path = "/var/lib/lxc/"
cgroup_path = "/sys/fs/cgroup/"

cont_name = sys.argv[1]


def showmemory():


def showcpuusage():

def showsystem():
    

def showstate():
    state = lxc.Container(cont_name).state.swapcase()
    print(state)
