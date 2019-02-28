
Using zram-config_0.5_all.deb some initial tests on a Pi0 with a budget Kingston Class10 16GB MicroSD
First sheet no zram
2nd sheet Default zram-config_0.5_all.deb .5* free mem
3rd sheet hacked zram-config_0.5_all.deb .5* freem mem LZ4

Running MagicMirror2 with quick 15sec page rotations using standard modules + MMM-News to create some I/O
Little script running cat /proc/loadavg every ten secs on MagicMirror initialisation.

PiZero should be a good yard stick as it has little precious cpu power to spare.
LZ0 would seem to be better than without LZ4 is approx the same as without.

Hack here for 3rd sheet with LZ4
```
#!/bin/sh

# load dependency modules
NRDEVICES=$(grep -c ^processor /proc/cpuinfo | sed 's/^0$/1/')
if modinfo zram | grep -q ' zram_num_devices:' 2>/dev/null; then
  MODPROBE_ARGS="zram_num_devices=${NRDEVICES}"
elif modinfo zram | grep -q ' num_devices:' 2>/dev/null; then
  MODPROBE_ARGS="num_devices=${NRDEVICES}"
else
  exit 1
fi
modprobe zram $MODPROBE_ARGS

# Calculate memory to use for zram (1/2 of ram)
totalmem=`LC_ALL=C free | grep -e "^Mem:" | sed -e 's/^Mem: *//' -e 's/  *.*//'`
mem=$(((totalmem / 2 / ${NRDEVICES}) * 1024))

# initialize the devices
for i in $(seq ${NRDEVICES}); do
  DEVNUMBER=$((i - 1))
  echo lz4 > /sys/block/zram${DEVNUMBER}/comp_algorithm
  echo $mem > /sys/block/zram${DEVNUMBER}/disksize
  mkswap /dev/zram${DEVNUMBER}
  swapon -p 5 /dev/zram${DEVNUMBER}
done

```
