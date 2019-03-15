# Log2Zram

Usefull for IoD / maker projects for reducing SD, Nand and Emmc block wear via log operations.
Uses Zram to minimise precious memory footprint and extremely infrequent write outs.

Log2Zam is a lower write fork https://github.com/azlux/log2ram based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)

Can not be used for mission critical logging applications where a system crash and log loss is unaceptable.
If the extremely unlikely event of a system crash is not a major concern then L2Z can massively reduce log block wear whilst maintinaing and extremely tiny memory footprint.

_____
## Menu
1. [Install](#install)
2. [Upgrade](#upgrade)
3. [Customize](#customize)
4. [It is working ?](#it-is-working)
5. [Uninstall](#uninstall-)

## Install

    git clone https://github.com/StuartIanNaylor/log2zram
    cd log2zram
    sudo sh install.sh
    

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

###### Now, muffins for everyone!


## Uninstall :(
(Because sometime we need it)
```
chmod +x /usr/local/bin/uninstall-log2ram.sh && sudo /usr/local/bin/uninstall-log2ram.sh
```
Also /var/oldlog contains the pruned logs from install delete if not required (prob not)
