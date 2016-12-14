#!/bin/bash

value=$1

cat /sys/kernel/mm/ksm/$value 2> /dev/null || echo "ZBX_NOTSUPPORTED"

exit 0
