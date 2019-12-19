# Log2Ram
Like ramlog for systemd (on debian 8 jessie for example).

Usefull for **RaspberryPi** for not writing on the SD card all the time. You need it because your SD card doesn't want to suffer anymore!

Explanations: The script creates a `/var/log` mount point in RAM. So any writing of the log to the `/var/log` folder will not actually be written to disk (in this case to the sd card for a raspberry card) but directly to RAM. By default, every days, the CRON will launch a synchronization of the RAM to the folder located on the physical disk. The script will also make this copy of RAM to disk in case of machine shutdown (but cannot do it in case of power failure). This way you avoid excessive writing on the SD card.

The script [log2ram](https://github.com/azlux/log2ram) can work on every linux system. So you can use it with your own daemon manager if you don't have systemd.

Log2Ram is based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)

_____
## Menu
1. [Install](#install)
2. [Upgrade](#upgrade)
3. [Customize](#customize)
4. [It is working ?](#it-is-working)
5. [Uninstall](#uninstall-)

## Install
### With APT (recommended)
    echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
    wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
    apt update
    apt install log2ram

### Manually
    curl -Lo log2ram.tar.gz https://github.com/azlux/log2ram/archive/master.tar.gz
    tar xf log2ram.tar.gz
    cd log2ram-master
    chmod +x install.sh && sudo ./install.sh
    cd ..
    rm -r log2ram-master

**REBOOT** before installing anything else (for example apache2)
## Upgrade

You need to stop log2ram (`service log2ram stop`) and start the [install](#install).

## Customize
#### variables :
In the file `/etc/log2ram.conf`, there are three variables:

- `SIZE`: defines the size the log folder will reserve into the RAM (default is 40M).
- `USE_RSYNC`: Can be set to `true` if you prefer ´rsync´ rather than ´cp´. I use the command `cp -u` and `rsync -X`, I don't copy the all folder every time for optimization.
- `MAIL`: Disables the error system mail if there is not enough place on RAM (if set to `false`)
- `ZL2R`: Enable zram compatibility (`false` by default). Check the comment on the config file. See https://github.com/StuartIanNaylor/zram-swap-config to configure a zram space on your raspberry before enable this option.

#### refresh time:
By default Log2Ram writes to the HardDisk every day. If you think this is too much, you can move `/etc/cron.daily/log2ram` in an other cron folder, or remove it if you prefer writing logs only at stop/reboot.

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

Compressor for zram. Usefull for the `COMP_ALG` of ZRAM on the config file.

| Compressor name	     | Ratio	| Compression | Decompress. |
|------------------------|----------|-------------|-------------|
|zstd 1.3.4 -1	         | 2.877	| 470 MB/s	  | 1380 MB/s   |
|zlib 1.2.11 -1	         | 2.743    | 110 MB/s    | 400 MB/s    |
|brotli 1.0.2 -0	     | 2.701	| 410 MB/s	  | 430 MB/s    |
|quicklz 1.5.0 -1	     | 2.238	| 550 MB/s	  | 710 MB/s    |
|lzo1x 2.09 -1	         | 2.108	| 650 MB/s	  | 830 MB/s    |
|lz4 1.8.1	             | 2.101    | 750 MB/s    | 3700 MB/s   |
|snappy 1.1.4	         | 2.091	| 530 MB/s	  | 1800 MB/s   |
|lzf 3.6 -1	             | 2.077	| 400 MB/s	  | 860 MB/s    |

###### Now, muffins for everyone!


## Uninstall :(
(Because sometime we need it)
```
chmod +x /usr/local/bin/uninstall-log2ram.sh && sudo /usr/local/bin/uninstall-log2ram.sh
```
