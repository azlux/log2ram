# Log2Ram
Like ramlog for systemd (on debian 8 jessie for example).

Usefull for **Raspberry** for not writing all the time on the SD card. You need it because your SD card don't want to suffer anymore !

The script [log2ram](https://github.com/azlux/log2ram) can work on every linux system. So you can use it with your own daemon manager if you don't have systemd.

Log2Ram is based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)

## Install
```
git clone https://github.com/azlux/log2ram.git
cd log2ram
chmod +x install.sh
sudo ./install.sh
```


## Customize
#### variables :
Into the file `/etc/log2ram.conf`, there are two variables :

- The first variable define the size the log folder will reserve into the RAM.
- The second variable can be set to `true` if you prefer "rsync" than "cp". I use the command `cp -u` and `rsync -X`, I don't copy the all folder every time for optimization.

#### refresh time:
The default is to write log into the HardDisk every hour. If you think this is too much, you can make the write every day by moving the cron file : `sudo mv /etc/cron.hourly/log2ram /etc/cron.daily/log2ram`.

### It is working ?
You can now check the mount folder in ram with (You will see lines with log2ram if working)
```
df -h
mount
```

The log for log2ram will be write here : `/var/log.hdd/log2ram.log`

###### Now, muffins for everyone !
