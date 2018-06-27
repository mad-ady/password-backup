#!/bin/bash

echo "Backing up $1"
backupsToKeep=20
destinations=()
destinations[0]=/backup/kppassword
destinations[1]=/media/ssd/ssd250/backup/kppassword

fullfile=$1
file=`basename "$1"`;
let "backupsToKeep++";

doBackup() {
    date=`date +%Y%m%d_%H%M%S`
    #copy to each destination
    for dst in ${destinations[@]}; do
        cp -av "$fullfile" "$dst/$date-$file"
    done
}

cleanup() {
    # find all backed up files with $file name and sort them by date. Keep last $backupsToKeep
    for dst in ${destinations[@]}; do
        cd "$dst"
        ls -1pt "$dst/"*-$file | tail -n +$backupsToKeep | xargs rm -fv 
    done
}

#see if the file is the same as the last one
if [ -f "/tmp/$file" ]; then
    # check the checksum of the old backup
    md5sum "$fullfile" > "/tmp/.$file"
    cmp "/tmp/.$file" "/tmp/$file"
    if [ "$?" -ne 0 ]; then
       # the file differs from the last backup
       doBackup
       cleanup
       mv "/tmp/.$file" "/tmp/$file"
    else
       # it's unchanged, skip backup
       echo "File is unchanged, skipping backup"
    fi
else
   # I don't know what the last backup was, do a backup now
   doBackup
   cleanup
   md5sum "$fullfile" > "/tmp/$file"
fi 


