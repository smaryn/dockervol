#!/bin/bash
# version 1.1.1

LOGFILE="/var/log/start_sh.log"
TAILCMD="$( which tail )"
NETSTAT="$( which netstat )"
DATE="$( which date )"

[[ "TRACE" ]] && set -x

debug() {
  [[ "DEBUG" ]]  && echo "[DEBUG] [$($DATE +"%T")] $@" 1>&2
}

fix_resolv_conf() {
  echo 'nameserver 8.8.8.8' > /etc/resolv.conf | tee -a $LOGFILE
}

start_httpd() {
  while [ -z "$($NETSTAT -tulpn | grep -w 80)" ]; do
    # service httpd start
    exec /usr/sbin/apachectl -DFOREGROUND | tee -a $LOGFILE
    sleep 30
  done
}
main() {
  touch $LOGFILE
  fix_resolv_conf
  # service sshd start | tee -a $LOGFILE
  # Make sure we're not confused by old, incompletely-shutdown httpd
  # context after restarting the container.  httpd won't start correctly
  # if it thinks it is already running.
  rm -rf /run/httpd/* /tmp/httpd*
  # start_httpd

   while true; do
     sleep 3
     $TAILCMD -f $LOGFILE
   done
}

main "$@"
