#!/bin/bash
crontab -l > mycron
echo '* * * * * /usr/local/bin/log2ram-scheduler 2>&1 | /usr/bin/logger -t log2ram-scheduler' >> mycron
crontab mycron
rm mycron
