#!/usr/bin/env sh

[ "$(id -u)" -eq 0 ] || { echo "You need to be ROOT (sudo can be used)"; exit 1; }

# See if we can find out the init-system
echo "Try to detect init..."
if [ "$(systemctl --version)" != '' ] ; then
  INIT='systemd'
elif [ "$(rc-service --version)" != '' ] ; then
  INIT='openrc'
fi

case "$INIT" in
  systemd)
    systemctl -q is-active log2ram  && { echo "ERROR: log2ram service is still running. Please run \"sudo service log2ram stop\" to stop it."; exit 1; } ;;
  openrc)
    rc-service log2ram status  && { echo "ERROR: log2ram service is still running. Please run \"sudo rc-service log2ram stop\" to stop it."; exit 1; } ;;
  *) echo 'ERROR: could not detect init-system' ; exit 1
  ;;
esac
  
# log2ram
mkdir -p /usr/local/bin/
install -m 755 log2ram /usr/local/bin/log2ram
install -m 644 log2ram.conf /etc/log2ram.conf
install -m 644 uninstall.sh /usr/local/bin/uninstall-log2ram.sh
if [ "$INIT" = 'systemd' ] ; then
  install -m 644 log2ram.service /etc/systemd/system/log2ram.service
  systemctl enable log2ram
elif [ "$INIT" = 'openrc' ] ; then
  install -m 755 log2ram.initd /etc/init.d/log2ram
  rc-update add log2ram boot
fi

# cron
if [ "$INIT" = 'systemd' ] ; then
  install -m 755 log2ram.cron /etc/cron.daily/log2ram
elif [ "$INIT" = 'openrc' ] ; then
  install -m 755 log2ram.openrc_cron /etc/cron.daily/log2ram
fi
install -m 644 log2ram.logrotate /etc/logrotate.d/log2ram

# Remove a previous log2ram version
rm -rf /var/log.hdd

# Make sure we start clean
rm -rf /var/hdd.log

echo "#####         Reboot to activate log2ram         #####"
echo "##### edit /etc/log2ram.conf to configure options ####"
