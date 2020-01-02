#!/usr/bin/env sh

[ "$(id -u)" -eq 0 ] || { echo "You need to be ROOT (sudo can be used)"; exit 1; }

# See if we can find out the init-system
echo "Try to detect init..."
if [ "$(systemctl --version)" != '' ] ; then
  INIT='systemd'
elif [ "$(rc-service --version)" != '' ] ; then
  INIT='openrc'
fi

if [ "$INIT" = 'systemd' ] ; then
  service log2ram stop
  systemctl disable log2ram
  rm /etc/systemd/system/log2ram.service
elif [ "$INIT" = 'openrc' ] ; then
  rc-service log2ram stop
  rc-update del log2ram boot
  rm /etc/init.d/log2ram
fi

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
