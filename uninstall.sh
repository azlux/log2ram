#!/usr/bin/env sh

if [ "$(id -u)" -eq 0 ]
then
  systemctl stop log2ram.service log2ram-daily.timer
  systemctl disable log2ram.service log2ram-daily.timer
  rm -rf /etc/systemd/system/log2ram*
  rm /usr/local/bin/log2ram
  rm /etc/log2ram.conf
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
