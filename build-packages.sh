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

# Remove potential leftovers from a previous build
rm -rf "$DESTDIR" "$OUTDIR"


## log2ram
# Create directory
install -Dm 644 "$STARTDIR/log2ram.service" "$DESTDIR/etc/systemd/system/log2ram.service"
install -Dm 755 "$STARTDIR/log2ram" "$DESTDIR/usr/local/bin/log2ram"
install -Dm 644 "$STARTDIR/log2ram.conf" "$DESTDIR/etc/log2ram.conf"
install -Dm 644 "$STARTDIR/uninstall.sh" "$DESTDIR/usr/local/bin/uninstall-log2ram.sh"

# cron
install -Dm 755 "$STARTDIR/log2ram.cron" "$DESTDIR/etc/cron.daily/log2ram"
install -Dm 644 "$STARTDIR/log2ram.logrotate" "$DESTDIR/etc/logrotate.d/log2ram"

# Build .deb
mkdir "$DESTDIR/DEBIAN" "$OUTDIR"
cp "$STARTDIR/debian/"* "$DESTDIR/DEBIAN/"
dpkg-deb --build "$DESTDIR" "$OUTDIR"
reprepro -b /var/www/repos/apt/debian includedeb buster "$OUTDIR"/*.deb
reprepro -b /var/www/repos/apt/debian includedeb stretch "$OUTDIR"/*.deb

