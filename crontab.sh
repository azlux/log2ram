#!/bin/bash
crontab -l > mycron
echo '* * * * * /usr/local/bin/log2ram-scheduler 2>&1 /dev/null' >> mycron
crontab mycron
rm mycron
