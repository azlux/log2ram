#!/bin/bash

#
# cron.daily/log2ram -- daily write/sync ramlog to disk
#
#

LOG2RAM_SCRIPT=/usr/bin/log2ram
LOG2RAM_CONFIG=/etc/log2ram.conf

# Check if all is fine with the needed files
if [[ ! -f "${LOG2RAM_CONFIG}" ]]; then
    echo "${LOG2RAM_CONFIG} not found"
    exit 1
fi

if [[ ! -x "${LOG2RAM_SCRIPT}" ]]; then
    echo "${LOG2RAM_SCRIPT} not executable"
    exit 1
fi

if ! grep -w log2ram /proc/mounts >/dev/null; then
    echo "log2ram is NOT running"
    exit 1
fi

exec "${LOG2RAM_SCRIPT}" write
