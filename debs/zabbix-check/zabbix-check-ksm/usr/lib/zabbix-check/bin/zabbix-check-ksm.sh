#!/bin/sh

fail_ () {
	echo "ZBX_NOTSUPPORTED"
	exit 1
}

[ $# -eq 1 ] || fail_
[ -d /sys/kernel/mm/ksm ] || fail_

read value 2>/dev/null </sys/kernel/mm/ksm/$1 && printf $value || fail_
exit 0

