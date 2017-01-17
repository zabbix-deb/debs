#!/bin/bash

pid=$(sudo lxc-info -n $1 | head -4 | tail -1 | grep -o -e '[0-9\-]*')

if [ -z $pid ]; then
        echo 0
else
        echo $pid
fi
exit 0
