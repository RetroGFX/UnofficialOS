#!/usr/bin/env bash

TEMPFILE=$(mktemp -t diagnostic-XXXXXXXX)
DESTINATION="/roms/diagnostic-$(date +%Y%m%d%H%M).txt"

create_header() {
  local separator="=========================================================================="

cat << EOF >> $TEMPFILE
$separator
$1
$separator
EOF
}

create_header "system.cfg"
cat /storage/.config/system/configs/system.cfg | grep -vE "^(wifi.key|root.password|global.retroachievements.password)" >> $TEMPFILE

create_header "dmesg"
dmesg >> $TEMPFILE

create_header "iw"
iw list >> $TEMPFILE

create_header "amionline"
amionline || true >> $TEMPFILE

for logfile in /var/log/*.log; do
  create_header $logfile
  cat $logfile >> $TEMPFILE
done

mv $TEMPFILE $DESTINATION