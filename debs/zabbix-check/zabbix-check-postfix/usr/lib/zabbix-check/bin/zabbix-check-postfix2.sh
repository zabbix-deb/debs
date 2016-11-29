#!/bin/bash
var=$1

if ! which postqueue >/dev/null; then
	echo -2
	exit -2
fi

case $var in
	deferred)
		/usr/sbin/postqueue -p | egrep -c "^[0-9A-F]{10}[^*]"
		;;
	active)
		/usr/sbin/postqueue -p | egrep -c "^[0-9A-F]{10}[*]"
		;;
	*)
		echo -1
		exit -1
esac
exit 0

