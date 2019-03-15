#!/bin/bash

systemctl -q is-active log2zram  && { echo "ERROR: log2zram service is still running. Please run \"sudo service log2zram stop\" to stop it and uninstall"; exit 1; }
[ "$(id -u)" -eq 0 ] || { echo "You need to be ROOT (sudo can be used)"; exit 1; }

# log2ram
mkdir -p /usr/local/bin/log2zram
install -m 644 log2zram.service /etc/systemd/system/log2zram.service
install -m 755 log2zram /usr/local/bin/log2zram/log2zram
install -m 644 log2zram.conf /etc/log2zram.conf
install -m 644 log2zram.log /usr/local/bin/log2zram/log2zram.log
install -m 644 uninstall.sh /usr/local/bin/log2zram/uninstall.sh
systemctl enable log2zram

# cron
install -m 755 log2zram.hourly /etc/cron.hourly/log2zram
install -m 644 log2zram.logrotate /etc/logrotate.d/log2zram

# Make sure we start clean
rm -rf /var/hdd.log
# Make backup of pruned logs
mkdir -p /var/oldlog

cp -rfup /var/log/*.1 /var/oldlog/
cp -rfup /var/log/*.gz /var/oldlog/
cp -rfup /var/log/*.old /var/oldlog/
# Prune logs
rm -r /var/log/*.1
rm -r /var/log/*.gz
rm -r /var/log/*.old
# Clone /var/log
mkdir -p /var/hdd.log
mkdir -p /var/log/oldlog
# Prob better to use xcopy here with a --exclude
rsync -arzh --exclude 'oldlog' /var/log/ /var/hdd.log/
mkdir -p /var/hdd.log/oldlog
sed -i '/^include.*/i olddir /var/log/oldlog' /etc/logrotate.conf

echo "#####          Reboot to activate log2ram         #####"
echo "##### edit /etc/log2zram.conf to configure options #####"
