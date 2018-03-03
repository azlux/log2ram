# Log2Ram
Like ramlog for systemd (on debian 8 jessie for example).

Usefull for **RaspberryPi** for not writing on the SD card all the time. You need it because your SD card doesn't want to suffer anymore!

The script [log2ram](https://github.com/azlux/log2ram) can work on every linux system. So you can use it with your own daemon manager if you don't have systemd.

Log2Ram is based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)

## Install

    curl -Lo log2ram.tar.gz https://github.com/azlux/log2ram/archive/master.tar.gz
    tar xf log2ram.tar.gz
    cd log2ram-master
    chmod +x install.sh && sudo ./install.sh
    cd ..
    rm -r log2ram-master

**REBOOT** before installing anything else (for example apache2)

## Customize
#### variables :
In the file `/etc/log2ram.conf`, there are three variables:

- `SIZE`: defines the size the log folder will reserve into the RAM (default is 40M).
- `USE_RSYNC`: Can be set to `true` if you prefer ´rsync´ rather than ´cp´. I use the command `cp -u` and `rsync -X`, I don't copy the all folder every time for optimization.
- `MAIL`: Disables the error system mail if there is not enough place on RAM (if set to `false`)

#### refresh time:
By default Log2Ram writes to the HardDisk every hour. If you think this is too much, you can make the write every day by moving the cron file to daily: `sudo mv /etc/cron.hourly/log2ram /etc/cron.daily/log2ram`.

### It is working?
You can now check the mount folder in ram with (You will see lines with log2ram if working)
```
# df -h
…
log2ram          40M  532K   40M   2% /var/log
…

# mount
…
log2ram on /var/log type tmpfs (rw,nosuid,nodev,noexec,relatime,size=40960k,mode=755)
…
```

If you have issue with apache2, you can try to add `apache2.service` next to other services on the `Before` parameter in `/etc/systemd/system/log2ram.service` it will solve the pb

The log for log2ram will be written at: `/var/log/log2ram.log`

###### Now, muffins for everyone!


## Uninstall :(
(Because sometime we need it)
```
chmod +x /usr/local/bin/uninstall-log2ram.sh && sudo /usr/local/bin/uninstall-log2ram.sh
```
