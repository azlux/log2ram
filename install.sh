#!/bin/sh

if [ `id -u` -eq 0 ]
then
  cp log2ram.service /etc/systemd/system/log2ram.service
  chmod a+x /etc/systemd/system/log2ram.service
  cp log2ram /usr/local/bin/log2ram
  chmod a+x /usr/local/bin/log2ram
  systemctl enable log2ram
  
  echo "Reboot to activate log2ram"
else 
  echo "You need to be ROOT (sudo can be used)"
fi
