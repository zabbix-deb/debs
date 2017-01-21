#!/bin/bash

ns=$1
if [ "$ns" = "" ]; then
	exit 1
fi

dig -4 +time=2 @$ns $ns +short >/dev/null 2>&1
v4=$?
dig -6 +time=2 @$ns $ns +short >/dev/null 2>&1
v6=$?

echo $(( $v4 + $v6 ))
exit 0
