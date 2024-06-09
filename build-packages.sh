#!/usr/bin/env bash

# Exit the script if any of the commands fail
set -e
set -u
set -o pipefail

# Set working directory to the location of this script
cd "$(dirname "${BASH_SOURCE[0]}")"

STARTDIR="$(pwd)"
DESTDIR="$STARTDIR/pkg"
OUTDIR="$STARTDIR/deb"
# get version
repo="azlux/log2ram"
api=$(curl --silent "https://api.github.com/repos/$repo/releases" | jq ".[0]")
new=$(echo $api | grep -Po '"tag_name": "\K.*?(?=")')

# Remove potential leftovers from a previous build
rm -rf "$DESTDIR" "$OUTDIR"

## log2ram
# Create directory
install -Dm 644 "$STARTDIR/log2ram.service" "$DESTDIR/etc/systemd/system/log2ram.service"
install -Dm 644 "$STARTDIR/log2ram-daily.service" "$DESTDIR/etc/systemd/system/log2ram-daily.service"
install -Dm 644 "$STARTDIR/log2ram-daily.timer" "$DESTDIR/etc/systemd/system/log2ram-daily.timer"
install -Dm 755 "$STARTDIR/log2ram" "$DESTDIR/usr/local/bin/log2ram"
install -Dm 644 "$STARTDIR/log2ram.conf" "$DESTDIR/etc/log2ram.conf"
install -Dm 644 "$STARTDIR/uninstall.sh" "$DESTDIR/usr/local/bin/uninstall-log2ram.sh"

# logrotate
install -Dm 644 "$STARTDIR/log2ram.logrotate" "$DESTDIR/etc/logrotate.d/log2ram"

# Build .deb
mkdir "$DESTDIR/DEBIAN" "$OUTDIR"
cp "$STARTDIR/debian/"* "$DESTDIR/DEBIAN/"

# Set version
sed -i "s/VERSION-TO-REPLACE/$new/" "$DESTDIR/DEBIAN/control"

dpkg-deb --build "$DESTDIR" "$OUTDIR"
