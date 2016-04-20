# Log2Ram
Like ramlog for systemd on debian 8 jessie.

Usefull for **Raspberry** for not writing all the time on the SD card. You need it because your SD card don't want to suffer anymore !

Log2Ram is based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)

## Install
```
git clone https://github.com/azlux/log2ram.git
cd log2ram
chmod +x install.sh
sudo ./install.sh
```

#####It is working ?
You can now check the mount folder in ram with
```
df -h
mount
```
and change size into /usr/bin/log2ram if necessary

######Now, muffins for everyone !
