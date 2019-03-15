# Log2Zram

Usefull for IoD / maker projects for reducing SD, Nand and Emmc block wear via log operations.
Uses Zram to minimise precious memory footprint and extremely infrequent write outs.

Log2Zam is a lower write fork https://github.com/azlux/log2ram based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)

Can not be used for mission critical logging applications where a system crash and log loss is unaceptable.
If the extremely unlikely event of a system crash is not a major concern then L2Z can massively reduce log block wear whilst maintinaing and extremely tiny memory footprint.

_____
## Menu
1. [Install](#install)
2. [Config](#config)
3. [It is working ?](#it-is-working)
4. [Uninstall](#uninstall-)

## Install
    sudo apt-get install git rsync
    git clone https://github.com/StuartIanNaylor/log2zram
    cd log2zram
    sudo sh install.sh
    

## Customize
#### variables :
In the file `/etc/log2zram.conf` sudo nano /etc/log2zram.conf to edit:
```
# Configuration file for Log2Ram (https://github.com/azlux/log2ram) under MIT license.
# This configuration file is read by the log2ram service

# Size for the zram memory used, it defines the mem_limit for the zram device.
# The default is 20M and is basically enough for minimal applications.
# Because aplications can often vary in logging frequency this may have to be tweaked to suit application .
SIZE=20M
# ZL2R Zram Log 2 Ram enables a zram drive when ZL2R=true ZL2R=false is mem only tmpfs
ZL2R=true
# COMP_ALG this is any compression algorithm listed in /proc/crypto
# lz4 is fastest with lightest load but deflate (zlib) and Zstandard (zstd) give far better compression ratios
# lzo is very close to lz4 and may with some binaries have better optimisation
# COMP_ALG=lz4 for speed or deflate for compression, lzo or zlib if optimisation or availabilty is a problem
COMP_ALG=lz4
# LOG_DISK_SIZE is the uncompressed disk size. Note zram uses about 0.1% of the size of the disk when not in use
# LOG_DISK_SIZE is expected compression ratio of alg chosen multiplied by log SIZE where 300% is an approx good level.
# lzo/lz4=2.1:1 compression ratio zlib=2.7:1 zstandard=2.9:1
# Really a guestimate of a bit bigger than compression ratio whilst minimising 0.1% mem usage of disk size
LOG_DISK_SIZE=60M
# PRUNE_LEVEL if log size is below this level then old logs will be moved to hdd.log enter as %
# Moving the old logs will restart log rotation as old logs will no longer exist in /var/log/oldlog
# In normal operation hitting 50% or above can take many hourly cycles so a higher prune level is a balance
# 55-60% is probably a good level as too high will restart logrotation and create less history  
PRUNE_LEVEL=60
``

#### refresh time:
By default Log2Zram checks available log space every hour. It them makes a comparison of the percentage set via Prune_Level and only writes out old logs to disk when triggered and then removes the collected old logs from zram space.

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
### Testing
```
sudo service log2ram reload
```
Checks PRUNE_LEVEL < available free space if true will move and clean /var/log/oldlog to hdd.log
```
sudo logrotate -vf /etc/logrotate.conf
```
Force the daily logrotate with verbose output

If you have issue with apache2, you can try to add `apache2.service` next to other services on the `Before` parameter in `/etc/systemd/system/log2ram.service` it will solve the pb

The log for log2ram will be written at: `/var/log/log2ram.log`

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


## Uninstall :(
```
chmod +x /usr/local/bin/uninstall-log2ram.sh && sudo /usr/local/bin/uninstall-log2ram.sh
```
Also /var/oldlog contains the pruned logs from install delete if not required (prob not)
