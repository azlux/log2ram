#!/usr/bin/env bash

if [[ "$(id -u)" -ne 0 ]]; then
    echo "You need to be ROOT (sudo can be used)"
    exit 1
fi

if dpkg -l log2ram 2>/dev/null; then
    echo "Please run: apt remove log2ram"
    exit 1
fi

echo "Not apt installed. Remove will continue with this script..."

systemctl stop log2ram.service log2ram-daily.timer
systemctl disable log2ram.service log2ram-daily.timer

rm -rf /etc/systemd/system/log2ram*
rm -f /usr/local/bin/log2ram
rm -f /etc/log2ram.conf
rm -f /etc/logrotate.d/log2ram

if [[ -d /var/hdd.log ]]; then
    rm -rf /var/hdd.log
fi

echo "Log2Ram is uninstalled, removing the uninstaller in progress"
rm -f /usr/local/bin/uninstall-log2ram.sh
echo "##### Reboot isn't needed #####"
