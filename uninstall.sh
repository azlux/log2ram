#!/bin/sh

if [ `id -u` -eq 0 ]
then
  service log2ram stop
  systemctl disable log2ram
  rm /etc/systemd/system/log2ram.service
  rm /usr/local/bin/log2ram
  rm etc/log2ram.conf
  rm /etc/cron.hourly/log2ram
  echo "##### Reboot isn't needed #####"
else
  echo "You need to be ROOT (sudo can be used)"
fi