# Log2Ram

Log2Ram works just like ramlog for systemd (on Debian 8 Jessie for example).

Useful for **Raspberry Pi** for not writing on the SD card all the time. You need it because your SD card doesn't want to suffer anymore!

Explanation: The script creates a `/var/log` mount point in RAM. So any writing of the log to the `/var/log` folder will not actually be written to disk (in this case to the SD card on a Raspberry Pi) but directly to RAM. By default, every day the CRON job will synchronize the contents in RAM with the folder located on the physical disk. The script will also make this copy of RAM to disk in case of machine shutdowns (but, of course, it still won't do it in case of power failures). This way you can avoid excessive writing on the SD card and extend its life.

[Log2Ram](https://github.com/azlux/log2ram)'s script works on every Linux system. If you don't have Systemd, you can still use Log2Ram with your own daemon manager.

Log2Ram is based on transient `/var/log` for Systemd. For more information, check [here](https://www.debian-administration.org/article/661/A_transient_/var/log).

---

## Table of Contents

1. [Installation](#installation)
2. [Is it working?](#is-it-working)
3. [Upgrading](#upgrading)
4. [Customization](#customization)
5. [Troubleshooting](#troubleshooting)
6. [Uninstallation](#uninstallation-)

## Installation

### Via APT (recommended) (generalized)

```bash
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ $(bash -c '. /etc/os-release; echo ${VERSION_CODENAME}') main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg
sudo apt update
sudo apt install log2ram
```

#### Debian 13 (Trixie)

Due to the issue described in [log2ram#259](https://github.com/azlux/log2ram/issues/259), Debian 13 Trixie users may need to ensure that APT installs Log2Ram from the correct source.  
To do this, create an APT pinning file that gives Log2Ram a higher priority:

```bash
sudo tee "/etc/apt/preferences.d/log2ram.pref" >/dev/null <<EOF
Package: log2ram
Pin: origin packages.azlux.fr
Pin-Priority: 1001
EOF
```

This forces APT to prefer the Log2Ram package from `packages.azlux.fr`, which avoids installation issues on Debian 13 until the upstream problem is resolved.

### Manually

```bash
curl -L https://github.com/azlux/log2ram/archive/master.tar.gz | tar zxf -
cd log2ram-master
chmod +x install.sh && sudo ./install.sh
cd ..
rm -r log2ram-master
```

For better performances, `rsync` is a recommended package.

**REBOOT** before installing anything else (for example `apache2`)

## Is it working?

After installing and rebooting, use systemctl to check if Log2Ram started successfully:

```bash
systemctl status log2ram
```

This will show a color-coded status (green: active/red: failed), as well as the last few log lines. To show the full log (scrolled to the end), run:

```bash
journalctl -u log2ram -e
```

The log is also written to `/var/log/log2ram.log`.

You can also inspect the mount folder in RAM with:

```bash
df -hT | grep log2ram | awk '{print " Name: " $1 "\nMount: " $7 "\n Type: " $2 "\nUsage: " $6 "\n Size: " $3 "\n Used: " $4 "\n Free: " $5}'
```

Returns:

```bash
 Name: log2ram
Mount: /var/log
 Type: tmpfs
Usage: 72%
 Size: 128M
 Used: 93M
 Free: 36M
```

Or also:

```bash
mount | grep log2ram | awk -F'[ ()]+' '{print "   Name: " $1 "\n  Mount: " $3 "\n   Type: " $5 "\nOptions: " $6}'
```

Returns:

```bash
   Name: log2ram
  Mount: /var/log
   Type: tmpfs
Options: rw,nosuid,nodev,noexec,noatime,size=131072k,mode=755,uid=100000,gid=100000,inode64
```

If you do not get any line as response of these commands, something is not working. Refer to [this section](#is-it-working).

## Upgrading

You need to stop Log2Ram (`systemctl stop log2ram`) and execute the [installation](#installation) process. If you used APT, this will be done automatically.

## Customization

### Variables

In the file `/etc/log2ram.conf`, there are nine variables:

- `SIZE`: defines the size the log folder will reserve into the RAM (default is `128M`).
- `USE_RSYNC`: (commented out by default = `true`) use `cp` instead of `rsync` (if set to `false`).
- `NOTIFICATION`: disables the notification system mail if there is not enough place in RAM (if set to `false`).
- `NOTIFICATION_COMMAND`: Specify the command for sending error notifications (By default, it uses the `mail` command).
- `PATH_DISK`: activate log2ram for other path than default one. Paths should be separated with a `;`.
- `JOURNALD_AWARE`: enable log rotation for journald logs before syncing. (default is `true`). Check the comment in the config file or the [Troubleshooting](#troubleshooting) section below for journald `SystemMaxUse` recommendations.
- `ZL2R`: enable zram compatibility (`false` by default). Check the comment in the config file. See <https://github.com/systemd/zram-generator> to configure a zram swap on your Raspberry Pi before enabling this option.
- `COMP_ALG`: choose a compression algorithm from those listed in /proc/crypto. (default is `lz4`). See [Compressor](#compressor) section below for options.
- `LOG_DISK_SIZE`: specifies the uncompressed zram disk size

### Refresh time

By default, Log2Ram writes to disk every day. If you think this is too much, you can run `systemctl edit log2ram-daily.timer` and for example add:

```ini
[Timer]
OnCalendar=
OnCalendar=Mon *-*-* 23:55:00
```

**Note**: The `OnCalendar=` line is important because it disables all existing times (e.g. the default one) for log2ram.

... Or even disable it altogether with `systemctl disable log2ram-daily.timer`, if you instead prefer Log2Ram to be writing logs only on system stops/reboots.

### Compressor

Compressor for ZRAM. Useful for the `COMP_ALG` of ZRAM in the config file.

| Compressor name      | Ratio  | Compression | Decompression |
|----------------------|--------|-------------|---------------|
| zstd 1.3.4 -1        | 2.877  | 470 MB/s    | 1380 MB/s     |
| zlib 1.2.11 -1       | 2.743  | 110 MB/s    | 400 MB/s      |
| brotli 1.0.2 -0      | 2.701  | 410 MB/s    | 430 MB/s      |
| quicklz 1.5.0 -1     | 2.238  | 550 MB/s    | 710 MB/s      |
| lzo1x 2.09 -1        | 2.108  | 650 MB/s    | 830 MB/s      |
| lz4 1.8.1            | 2.101  | 750 MB/s    | 3700 MB/s     |
| snappy 1.1.4         | 2.091  | 530 MB/s    | 1800 MB/s     |
| lzf 3.6 -1           | 2.077  | 400 MB/s    | 860 MB/s      |

**Now, muffins for everyone!**

## Troubleshooting

### Existing content in `/var/log` too large for RAM

One thing that stops Log2Ram from functioning is if `/var/log` is too large before starting Log2Ram the first time. This can happen if logs had been collected for a long time before installing Log2Ram itself. Find the largest directories in `/var/log` (this example command only shows the 3 largest):

```bash
sudo du -hs /var/log/* | sort -h | tail -n 3
```

If the `/var/log/journal` is very large, then there are a lot of system logs. Deletion of old "archived" logs can be fixed by adjusting a setting. Edit the `/etc/systemd/journald.conf` file and add the following option:

```bash
SystemMaxUse=20M
```

**Or** the more radical version of directly flushing the journal to a size that matches log2ram size imediately _(Be aware that this flish flush the systemd journal logs imediately to the given size!)_

```bash
journalctl --vacuum-size=32M
```

This should be set to a value smaller than the size of the RAM volume; for example, half of it could be fine. Then, apply the new setting:

```bash
sudo systemctl restart systemd-journald
```

This should shrink the size of "archived" logs to be below the newly imposed limit. Reboot and check that Log2Ram now works properly:

```bash
sudo reboot
```

Wait until system reboots...

```bash
systemctl status log2ram
```

## Uninstallation :(

(Because sometimes we need it)

### Via APT

```bash
sudo apt remove log2ram
```

You can add the `--purge` argument to remove Log2Ram config files as well.

### Manually

```bash
chmod +x /usr/local/bin/uninstall-log2ram.sh && sudo /usr/local/bin/uninstall-log2ram.sh
```
