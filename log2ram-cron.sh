#!/bin/bash
#
# cron.daily/log2ram -- daily write/sync ramlog to disk
#
#
LOG2RAM_SCRIPT=/usr/bin/log2ram
CONFIG=/etc/log2ram.conf
# Check if all is fine with the needed files
[ -f $CONFIG ] || exit 1
[ -x $LOG2RAM_SCRIPT ] || exit 1
cat /proc/mounts | grep -w log2ram > /dev/null || { echo -ne "log2ram is NOT running\n"; exit 1; }

exec ${LOG2RAM_SCRIPT} write
