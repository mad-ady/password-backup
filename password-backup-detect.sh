#!/bin/bash
DIR=/var/www/html/kppassword

while [ : ];
do
    #wait for a file to change
    echo "Waiting for a change in $DIR"
    inotifywait -e close_write,move,delete "$DIR/"*.kdbx
    #wait for things to stabilize
    sleep 2
    #find which file changed a few seconds ago
    find "$DIR" -name '*.kdbx' -type f -newermt '-4 seconds' -execdir /usr/local/bin/password-backup-execute.sh {} \;
done    
