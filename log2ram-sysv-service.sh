#!/bin/bash

#
# log2ram SysV Init script
# Developed by kivanov for VenusOS
#

### BEGIN INIT INFO
# Provides:          log2ram
# Required-Start:    $local_fs
# Required-Stop:
# Default-Start:     2 3 4 5 S
# Default-Stop:      0 1 6
# Short-Description: Provides ramdrive for system logging
### END INIT INFO

# Init start
START=06
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
LOG2RAM_SCRIPT=/usr/bin/log2ram
LOG2RAM_CONFIG=/etc/log2ram.conf

# Check if all is fine with the needed files
[[ -f "${LOG2RAM_CONFIG}" ]] || exit 1
[[ -x "${LOG2RAM_SCRIPT}" ]] || exit 1

# Source function library.
if [[ -f /etc/init.d/functions ]]; then
    # shellcheck disable=SC1091
    . /etc/init.d/functions
elif [[ -f /etc/rc.d/init.d/functions ]]; then
    # shellcheck disable=SC1091
    . /etc/rc.d/init.d/functions
fi

case "$1" in
start)
    echo -n "Starting log2ram: "
    #touch /data/log2ram.started.$(date +"%Y-%m-%d_%T")
    "${LOG2RAM_SCRIPT}" start
    RETVAL=$?
    if [[ "${RETVAL}" -eq 0 ]]; then
        echo "OK"
    else
        echo "FAIL"
    fi
    ;;
stop)
    echo -n "Stopping log2ram: "
    #touch /data/log2ram.stopped.$(date +"%Y-%m-%d_%T")
    "${LOG2RAM_SCRIPT}" stop
    RETVAL=$?
    if [[ "${RETVAL}" -eq 0 ]]; then
        echo "OK"
    else
        echo "FAIL"
    fi
    ;;
sync)
    echo -n "This operation is generally provided by cron."
    while true; do
        read -r -p "Continue (y/n)?" choice
        case "${choice}" in
        [Yy]*) break ;;
        [Nn]*) exit 1 ;;
        *) echo "Please answer yes or no." ;;
        esac
    done

    echo -n "Force log2ram write to disk on-the-fly from the cli: "
    #touch /data/log2ram.synched.$(date +"%Y-%m-%d_%T")
    "${LOG2RAM_SCRIPT}" write
    RETVAL=$?
    if [[ "${RETVAL}" -eq 0 ]]; then
        echo "OK"
    else
        echo "FAIL"
    fi
    ;;
status)
    cat /proc/mounts | grep -w log2ram >/dev/null && { echo -ne "log2ram is running\n"; }
    cat /proc/mounts | grep -w log2ram >/dev/null || { echo -ne "log2ram is NOT running\n"; }
    exit $?
    ;;
restart)
    $0 stop && sleep 1 && $0 start
    ;;
force-reload)
    $0 stop && sleep 1 && $0 start
    ;;
*)
    echo "Usage: /etc/init.d/$(basename "$0") {start|stop|sync|status|restart}"
    exit 1
    ;;
esac

exit 0
