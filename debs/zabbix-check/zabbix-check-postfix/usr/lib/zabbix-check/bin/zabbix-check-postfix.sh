#!/usr/bin/env bash

MAILLOG=/var/log/mail.log
if [ ! -s $MAILLOG ] && [ -s "/var/log/mail.info" ]; then
  MAILLOG=/var/log/mail.info
fi
PFOFFSETFILE=/tmp/zabbix-postfix-offset.dat
PFSTATSFILE=/tmp/zabbix-postfix-statsfile.dat
PFLOGSUMM=/usr/sbin/pflogsumm
[ -x ${PFLOGSUMM} ] || exit 1
LOGTAIL=/usr/sbin/logtail
[ -x ${LOGTAIL} ] || exit 1

TEMPFILE=$(mktemp)
trap "rm -f $TEMPFILE" 0 1 2 5 15

PFVALS=( 'received' 'delivered' 'forwarded' 'deferred' 'bounced' 'rejected' 'held' 'discarded' 'reject_warnings' 'bytes_received' 'bytes_delivered' )

[ ! -e "${PFSTATSFILE}" ] && touch "${PFSTATSFILE}" && chown zabbix:zabbix "${PFSTATSFILE}"

printvalues() {
  key=$1
  pfkey=$(echo "$1" | tr '_' ' ')
  value=$(grep -m 1 "${pfkey}" $TEMPFILE | awk '{print $1}' | awk '/k|m/{p = /k/?1:2}{printf "%d\n", int($1) * 1024 ^ p}')
  old_value=$(grep -e "^${key};" "${PFSTATSFILE}" | cut -d ";" -f2)
  if [ -n "${old_value}" ]; then
    sed -i -e "s/^${key};${old_value}/${key};$((${old_value}+${value}))/" "${PFSTATSFILE}"
  else
    echo "${key};${value}" >> "${PFSTATSFILE}"
  fi
}

if [ -n "$1" ]; then 
  key=$(echo ${PFVALS[@]} | grep -wo $1)
  if [ -n "${key}" ]; then
    value=$(grep -e "^${key};" "${PFSTATSFILE}" | cut -d ";" -f2)
    echo "${value}"
  else
    exit 2
  fi
else
  #TODO: intiligente versionsüberprüfung
  if [ "$(${PFLOGSUMM} --version | awk '{print $2}')" = "1.1.0" ] ; then 
    "${LOGTAIL}" -f"${MAILLOG}" -o"${PFOFFSETFILE}" | "${PFLOGSUMM}" -h 0 -u 0 --no_bounce_detail --no_deferral_detail --no_reject_detail --no_no_msg_size --no_smtpd_warnings > "${TEMPFILE}"
  else
    "${LOGTAIL}" -f"${MAILLOG}" -o"${PFOFFSETFILE}" | "${PFLOGSUMM}" -h 0 -u 0 --bounce_detail=0 --deferral_detail=0 --reject_detail=0 --no_no_msg_size --smtpd_warning_detail=0 > "${TEMPFILE}"
  fi
  for i in "${PFVALS[@]}"; do
    printvalues "$i"
  done
fi

