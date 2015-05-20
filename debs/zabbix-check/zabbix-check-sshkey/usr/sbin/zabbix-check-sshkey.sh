#!/bin/bash

keys=/root/.ssh/authorized_keys
if [ "$1" != "" ] && [  "$1" -eq "2" ]; then
	keys=/root/.ssh/authorized_keys2
fi

if [ -r $keys ]; then
	md5sum $keys | awk '{print $1}'
else
	echo 0
fi


