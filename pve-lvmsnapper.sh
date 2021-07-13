#!/bin/bash
export PATH=/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/sbin:/usr/local/bin

KEEP_DAYS=3 #How many days snapshots should be kept
VG="ThinVG01" #LVM volume group we are snapshoting
BACKUP_PREFIX="snap-" #Prefix for snapshotted volume
LOGFILE=/var/log/pvesnapper.log #log file for errors

# Create new snapshot
TODAY="$(date +%F)" 
    lvs | awk '{print $1}' | grep -v "snap" | grep -v "thinpool" | grep -v "LV" | grep "vm-" >/tmp/001 && for LV in $(cat /tmp/001);do lvcreate -s --name "$BACKUP_PREFIX$LV-$TODAY"  "$VG/$LV" 1>/dev/null 2>$LOGFILE;done #Find all VM related LVs and create a snapshot with TODAY's timestamp for each


# Clean old snapshots.
lvs -o lv_name --noheadings | sed -n "s@$BACKUP_PREFIX@@p" 1>/tmp/002 2>$LOGFILE #Find all snapshots and remove the "snap-" part from each
for LV in $(cat /tmp/001);do sed -n "s@$LV-@@p" /tmp/002 ;done 1>/tmp/003 2>$LOGFILE #Find all snapshots and filter them by their creation DATE 
cat /tmp/003 | while read DATE; do
      TS_DATE=$(date -d "$DATE" +%s)
      TS_NOW=$(date +%s)
      AGE=$(( (TS_NOW - TS_DATE) / 86400))
    if [ "$AGE" -ge "$KEEP_DAYS" ]; then
      echo $DATE 1>/tmp/004 2>$LOGFILE #Find snapshots older than $KEEP_DAYS
    fi
done
   if [ -f /tmp/004 ]; then
      for LV in $(cat /tmp/001);do lvremove -f $VG/$BACKUP_PREFIX$LV-$(cat /tmp/004) 1>/dev/null 2>$LOGFILE;done #Remove snapshots older than $KEEP_DAYS
   fi
   

# Cleanup orphaned snapshots
lvs -o lv_name --noheadings | sed -n "s@$BACKUP_PREFIX@@p"|cut -c '1-21'|uniq 1>/tmp/005 2>$LOGFILE #find all snapshots and remove prepending "snap-" and their date.
for LV in $(cat /tmp/005);do lvs -o lvname --noheadings $VG/$LV;done 1>/tmp/006 2>$LOGFILE #find all LVs related to the snapshots
cat /tmp/006|grep "Failed"|awk '{print $6}'|tr -d '"'|sed -e 's/$VG\///g'|cut -c '10-28' 1>/tmp/007 2>$LOGFILE #filter LVs which do not exist
for n in $(cat /tmp/007);do lvs -o lv_name --noheadings|grep $n 1>/tmp/008 2>$LOGFILE;done #find orphaned snapshots

if [ -f /tmp/008 ]; then
   for i in $(cat /tmp/008);do lvremove -f $VG/$i 1>/dev/null 2>$LOGFILE;done #remove orphaned snapshots
fi

rm /tmp/00* 2>$LOGFILE #cleanup temp files
