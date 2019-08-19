#!/usr/bin/env sh

if [ "$(id -u)" -eq 0 ]
then
  service log2ram stop
  systemctl disable log2ram
  rm /etc/systemd/system/log2ram.service
  rm /usr/local/bin/log2ram
  rm /etc/log2ram.conf
  rm /etc/cron.daily/log2ram
  rm /etc/logrotate.d/log2ram

  if [ -d /var/hdd.log ]; then
    rm -r /var/hdd.log
  fi
  echo "Log2Ram is uninstalled, removing the uninstaller in progress"
  rm /usr/local/bin/uninstall-log2ram.sh
  echo "##### Reboot isn't needed #####"
else
  echo "You need to be ROOT (sudo can be used)"
fi
