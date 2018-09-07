#!/bin/bash

KEEP_DAYS=3
VG="drbdpool" # LVM volume group we are snapshoting
BACKUP_PREFIX="snap-" # Prefix of snapshot volume name.


# Create new snapshot
TODAY="$(date +%F)" 
    lvs | awk '{print $1}' | grep -v "snap" | grep -v "thinpool" | grep -v "LV" | grep "vm-" > /tmp/001 && for LV in $(cat /tmp/001);do /sbin/lvcreate -s --name "$BACKUP_PREFIX$LV-$TODAY"  "$VG/$LV";done


# Clean old snapshots.
lvs -o lv_name --noheadings | sed -n "s@$BACKUP_PREFIX@@p" | while read DATE; do
    TS_DATE=$(date -d "$DATE" +%s)
    TS_NOW=$(date +%s)
    AGE=$(( (TS_NOW - TS_DATE) / 86400))
    if [ "$AGE" -ge "$KEEP_DAYS" ]; then
        VOLNAME="$BACKUP_PREFIX$DATE" 
        /sbin/lvremove -f "$VG/$VOLNAME" 
    fi
done

