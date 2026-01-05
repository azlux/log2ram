#!/usr/bin/env bash

if [[ "$(id -u)" -ne 0 ]]; then
    echo "You need to be ROOT (sudo can be used)"
    exit 1
fi

if systemctl -q is-active log2ram; then
    echo "ERROR: log2ram service is still running. Please run \"sudo systemctl stop log2ram\" to stop it."
    exit 1
fi

# log2ram
mkdir -p /usr/local/bin/
install -m 644 log2ram.service /etc/systemd/system/log2ram.service
install -m 644 log2ram-daily.service /etc/systemd/system/log2ram-daily.service
install -m 644 log2ram-daily.timer /etc/systemd/system/log2ram-daily.timer
install -m 644 uninstall.sh /usr/local/bin/uninstall-log2ram.sh
install -m 755 log2ram /usr/local/bin/log2ram

# Install config if not already present
if [[ ! -f /etc/log2ram.conf ]]; then
    install -m 644 log2ram.conf /etc/log2ram.conf
fi

systemctl enable log2ram.service log2ram-daily.timer

# logrotate
if [[ -d /etc/logrotate.d ]]; then
    install -m 644 log2ram.logrotate /etc/logrotate.d/log2ram
else
    echo "##### Directory /etc/logrotate.d does not exist. #####"
    echo "#####  Skipping log2ram.logrotate installation.  #####"
fi

# Remove a previous log2ram version
rm -rf /var/log.hdd

# Make sure we start clean
rm -rf /var/hdd.log

# Include config to check if size is enought (See below)
# shellcheck disable=SC1091
. /etc/log2ram.conf

# Validates that the SIZE variable is defined in the log2ram configuration file.
# Exits with an error message if the SIZE variable is not set, preventing further installation.
if [[ -z "${SIZE}" ]]; then
    echo "ERROR: SIZE variable is not defined in /etc/log2ram.conf"
    exit 1
fi

# Checks if the size of /var/log exceeds the specified SIZE threshold
# Returns an error if the size check fails or if the directory cannot be measured
# Exits the script with an error message if du command encounters issues
if ! du_output=$(du -sh -t "${SIZE}" /var/log 2>/dev/null); then
    echo "ERROR: Failed to check size of /var/log"
    exit 1
fi

# Check if var SIZE is sufficient and show a warning when too small
if [[ -n "${du_output}" ]]; then
    echo 'WARNING: Variable SIZE in /etc/log2ram.conf is too small to store the /var/log!'
    echo -n 'Actual size of /var/log is:'
    du -sh /var/log
    echo -e '\nPlease increase SIZE in /etc/log2ram.conf to avoid issues'
fi

echo "#####         Reboot to activate log2ram         #####"
echo "##### edit /etc/log2ram.conf to configure options ####"
