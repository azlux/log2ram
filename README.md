# Log2Ram
Like ramlog for systemd (on debian 8 jessie for example).

Usefull for **Raspberry** for not writing all the time on the SD card. You need it because your SD card don't want to suffer anymore !

The script [log2ram](log2ram) can work on every linux system. So you can use it with your own daemon manager if you don't have systemd.

Log2Ram is based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)

## Install
```
git clone https://github.com/azlux/log2ram.git
cd log2ram
chmod +x install.sh
sudo ./install.sh
```

into /usr/local/bin/log2ram
- You can change the SIZE variable if necessary
- If you prefer to use rsync, you can set the USE_RSYNC variable to `true`

## Customize
#### services :
If you open the file `/etc/systemd/system/log2ram.service` , you will see a line starting by `Before=`, you can list here the services who need to start after log2ram. You will need to change this line when a service start too fast and stop running because log2ram mount a ram folder where it has start to write log.

For example, If you use apache instead of nginx, add `apache2.service` into this line.

#### variables :
Into the file `log2ram` (or `/usr/local/bin/log2ram` if you have already installed it), there are two variables into the script : `SIZE=40M` and `USE_RSYNC=false`

The first variable define the size the log folder will reserve into the RAM.

The second variable can be set to `true` if you prefer "rsync" than "cp".

###It is working ?
You can now check the mount folder in ram with
```
df -h
mount
```
By default, the program will write log into the HardDisk every hour and the log for log2ram will be write here : `/var/log.hdd/log2ram.log`

######Now, muffins for everyone !
