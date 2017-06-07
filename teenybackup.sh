#!/bin/bash
## This script is called on the client being backed up.
## It could use a lot of polish, but it's served me well enough.
## Obviously there are no warranties or guarantees. Use at your own risk.

## This script requires pbzip2 be installed. If you don't have it, remove "--use-compress-program=pbzip2" from the tar command below



## FILE BACKUP PARAMETERS ##########################################################################
BACKUP_HOST="`cat /etc/hostname`"
BACKUP_PREFIX="myhostname__"
BACKUP_ROOT_DIR="/Backups"
BACKUP_DEST_FILE="$BACKUP_ROOT_DIR/$BACKUP_HOST/$BACKUP_PREFIX`date +%Y-%m-%d`.tar.bz2"
BACKUP_DEST_FILE_DIR="$BACKUP_ROOT_DIR/$BACKUP_HOST"
ROOT_DIRECTORY_TO_BACKUP=/
BACKUP_ARCHIVE_OWNER_USER=backup
NUMBER_OF_BACKUPS_TO_KEEP="2"

MYSQL_USER="SomeUser"
MYSQL_PASSWD="ChangeMe"
MYSQL_DUMP_FILE_PREFIX="All_Databases_Dump_"

## DO MYSQL DUMP ###################################################################################
rm /$MYSQL_DUMP_FILE_PREFIX*
mysqldump -u $MYSQL_USER -p$MYSQL_PASSWD --all-databases | bzip2 > /$MYSQL_DUMP_FILE_PREFIX`date +%Y-%m-%d`.bz2

## DO FILE BACKUP ##################################################################################
tar --exclude-backups --exclude-caches-all --atime-preserve --use-compress-program=pbzip2 -cpf $BACKUP_DEST_FILE --directory=$ROOT_DIRECTORY_TO_BACKUP .

#Below is what I used to call to grab the whole damn filesystem. Hah, crazy.
#tar --exclude-backups --exclude-caches-all --atime-preserve --use-compress-program=pbzip2 -cpf $BACKUP_DEST_FILE --directory=/ --exclude=var/cache/apt-cacher --exclude=proc --exclude=var/log/lastlog --exclude=sys --exclude=dev/pts --exclude=NFS --exclude=nfs .

chown $BACKUP_ARCHIVE_OWNER_USER: $BACKUP_DEST_FILE


## CLEANUP #########################################################################################
## Remove all previous backups except for the latest $NUMBER_OF_BACKUPS_TO_KEEP images
find $BACKUP_DEST_FILE_DIR/*.tar.bz2 -maxdepth 1 | sort -r | awk "NR>$NUMBER_OF_BACKUPS_TO_KEEP" | xargs rm


