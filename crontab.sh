#!/bin/bash
(crontab -l 2>/dev/null; echo '* * * * * /usr/local/bin/log2ram-scheduler 2>&1 | /usr/bin/logger -t log2ram-scheduler') | crontab -
