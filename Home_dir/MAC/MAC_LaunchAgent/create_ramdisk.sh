#!/bin/bash
LOG="/tmp/ramdisk_create.log"
exec >> "$LOG" 2>&1
echo "=== $(date) ==="
# Wait for disk arbitration to be ready (needed after reboot)
for i in $(seq 1 30); do
    DISK=$(/usr/bin/hdiutil attach -nomount ram://131072000 | tr -d '[:space:]')
    if [ -n "$DISK" ]; then
        echo "hdiutil succeeded on attempt $i: $DISK"
        sleep 1
        break
    fi
    echo "hdiutil attempt $i failed, retrying..."
    sleep 2
done
if [ -z "$DISK" ]; then
    echo "ERROR: hdiutil failed after 60s"
    exit 1
fi
/usr/sbin/diskutil apfs create "$DISK" RAMDisk && touch /Volumes/RAMDisk/.metadata_never_index
echo "Result: $?"