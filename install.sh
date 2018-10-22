#!/usr/bin/env sh

systemctl -q is-active log2ram  && { echo "ERROR: log2ram service is still running. Please run \"sudo service log2ram stop\" to stop it."; exit 1; }
[ "$(id -u)" -eq 0 ] || { echo "You need to be ROOT (sudo can be used)"; exit 1; }

# log2ram
mkdir -p /usr/local/bin/
install -m 644 log2ram.service /etc/systemd/system/log2ram.service
install -m 755 log2ram /usr/local/bin/log2ram
install -m 644 log2ram.conf /etc/log2ram.conf
install -m 644 uninstall.sh /usr/local/bin/uninstall-log2ram.sh
systemctl enable log2ram

# cron
install -m 755 log2ram.hourly /etc/cron.hourly/log2ram
install -m 644 log2ram.logrotate /etc/logrotate.d/log2ram

# Remove a previous log2ram version
  rm -rf /var/log.hdd

# Make sure we start clean
rm -rf /var/hdd.log

echo "##### Reboot to activate log2ram #####"
