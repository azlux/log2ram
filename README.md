# Log2Ram
Like ramlog for systemd (on debian 8 jessie for example).

Usefull for **RaspberryPi** for not writing on the SD card all the time. You need it because your SD card doesn't want to suffer anymore!

Explanations: The script creates a `/var/log` mount point in RAM. So any writing of the log to the `/var/log` folder will not actually be written to disk (in this case to the SD card for a Raspberry Pi) but directly to RAM. By default, every day, the CRON will launch a synchronization of the RAM to the folder located on the physical disk. The script will also make this copy of RAM to disk in case of machine shutdown (but cannot do it in case of power failure). This way you avoid excessive writing on the SD card.

The script [log2ram](https://github.com/azlux/log2ram) can work on every linux system. So you can use it with your own daemon manager if you don't have systemd.

Log2Ram is based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)

_____
## Table of Contents
1. [Install](#install)
2. [Is it working?](#is-it-working)
3. [Upgrade](#upgrade)
4. [Customize](#customize)
5. [Troubleshooting](#troubleshooting)
6. [Uninstall](#uninstall-)

## Install
### With APT (recommended)
    echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/azlux.list
    sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
    sudo apt update
    sudo apt install log2ram

### Manually
    curl -L https://github.com/azlux/log2ram/archive/master.tar.gz | tar zxf -
    cd log2ram-master
    chmod +x install.sh && sudo ./install.sh
    cd ..
    rm -r log2ram-master

For better performances. `RSYNC` is a recommended package.

**REBOOT** before installing anything else (for example apache2)

## Is it working?
After installing and rebooting, use systemctl to check if Log2Ram started successfully:

```
systemctl status log2ram
```

This will show a color-coded status (green active/red failed) as well as the last few log lines. To show the full log (scrolled to the end), run:

```
journalctl -u log2ram -e
```

The log is also written to `/var/log/log2ram.log`.

You can also inspect the mount folder in ram with (You will see lines with log2ram if working)
```
# df -h | grep log2ram
log2ram          40M  532K   40M   2% /var/log

# mount | grep log2ram
log2ram on /var/log type tmpfs (rw,nosuid,nodev,noexec,relatime,size=40960k,mode=755)
```

## Upgrade

You need to stop log2ram (`service log2ram stop`) and start the [install](#install). (APT will do it automatically)

## Customize
#### variables :
In the file `/etc/log2ram.conf`, there are five variables:

- `SIZE`: defines the size the log folder will reserve into the RAM (default is 40M).
- `USE_RSYNC`: (commented out by default = `true`) use `cp` instead of `rsync` (if set to `false`).
- `MAIL`: disables the error system mail if there is not enough place on RAM (if set to `false`).
- `PATH_DISK`: activate log2ram for other path than default one. Paths should be separated with a `;`.
- `ZL2R`: enable zram compatibility (`false` by default). Check the comment on the config file. See https://github.com/StuartIanNaylor/zram-swap-config to configure a zram space on your raspberry before enable this option.

#### refresh time:
By default Log2Ram writes to disk every day. If you think this is too much, you can run `systemctl edit log2ram-daily.timer` and add:

```ini
[Timer]
OnCalendar=
OnCalendar=Mon *-*-* 23:55:00
```
... or even disable it with `systemctl disable log2ram-daily.timer`, if you prefer writing logs only at stop/reboot.

#### compressor:
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

## Troubleshooting

### Existing content in `/var/log` too large for RAM

One thing that stops Log2Ram from starting is if `/var/log` is to large before starting Log2Ram the first time. This can happen if logs had been collected for a long time before installing Log2Ram. Find the largest directories in `/var/log` (this commands only shows the 3 largest):

```
sudo du -hs /var/log/* | sort -h | tail -n 3
```

If the `/var/log/journal` is very large, then there are a lot of system logs. Deletion of old "archived" logs can be fixed by adjusting a setting. Edit the `/etc/systemd/journald.conf` file and add the following option:

```
SystemMaxUse=20M
```

This should be set to a value smaller than the size of the RAM volume, for example half. Then apply the new setting:

```
sudo systemctl restart systemd-journald
```

This should shrink the size of "archived" logs to be below the limit. Reboot and check that Log2Ram succeds:

```
sudo reboot
…
systemctl status log2ram
```

## Uninstall :(
(Because sometime we need it)
### With APT
```
sudo apt remove log2ram
```
You can use `--purge` to remove config files as well.

### Manually
```
chmod +x /usr/local/bin/uninstall-log2ram.sh && sudo /usr/local/bin/uninstall-log2ram.sh
```
