#!/bin/bash
## This script is called on the client being backed up.
##
## In order to read various places like /etc fully, you'll need to run this as root. Note 
## that after the backup archive is created, ownership is changed to a backup user.

## FILE BACKUP PARAMETERS ##########################################################################
#BACKUP_PACKAGE_PREFIX="backup_"
#BACKUP_DIR_NAME="Backups"
#BACKUP_ROOT="/www/mydomain.com/www/$BACKUP_DIR_NAME"
#BACKUP_DEST_FILE_DIR="$BACKUP_ROOT/$BACKUP_PACKAGE_PREFIX`date +%Y-%m-%d`"
#BACKUP_SRC_DIR="/www/mydomain.com/www"
#BACKUP_PACKAGE_OWNER="backupuser"
#NUMBER_OF_BACKUPS_TO_KEEP="7"

#MYSQL_USER="yetanotherusername"
#MYSQL_PASSWD="myhighlysecurepassword"
#MYSQL_DUMP_FILE_DEST="$BACKUP_DEST_FILE_DIR/Database"
#MYSQL_DATABASENAME="mydatabase"

#FILE_COPY_DEST="$BACKUP_DEST_FILE_DIR/Files"

if [ "$#" -ne 1 ] ; then
	echo -e "Expected a parameter to be supplied directing us to a file of variables to source"
	exit -1
fi

if [ ! -f "$1" ] ; then
	echo -e "User supplied file $1 does not exist. Expect it to contains all required vars to run the script"
	exit -1
fi

source $1

USER_RUNNING_THIS=`whoami`

if [ "$USER_RUNNING_THIS" != "$BACKUP_PACKAGE_OWNER" ]; then
	echo "This was been run by $USER_RUNNING_THIS, it must be run by $BACKUP_PACKAGE_OWNER for safety's sake"
	exit 1
fi

mkdir -p $BACKUP_DEST_FILE_DIR/
if [ $? -ne 0 ]; then
	echo "Could not create $BACKUP_DEST_FILE_DIR as user $USER_RUNNING_THIS, this is a problem."
	exit 1
fi

mkdir -p $MYSQL_DUMP_FILE_DEST/
mkdir -p $FILE_COPY_DEST/


## DO MYSQL DUMP ###################################################################################
echo "Dumping database copy"
echo "mysqldump -u $MYSQL_USER -p$MYSQL_PASSWD $MYSQL_DATABASENAME | zip > $MYSQL_DUMP_FILE_DEST/$MYSQL_DATABASENAME__`date +%Y-%m-%d`.sql.zip"


## DO FILE COPY ####################################################################################
echo "Performing file copy"
echo "rsync -a --exclude="$BACKUP_DIR_NAME" --exclude="www_orig" $BACKUP_SRC_DIR/.. $FILE_COPY_DEST"


## COMPRESS ########################################################################################
if [ "$COMPRESS" = true ] ; then
	echo -e "Compression isn't yet implemented"
	#todo: decide on a schema for this. Suggest building for S3.
fi 

## CLEANUP #########################################################################################
## Remove all previous backups except for the latest $NUMBER_OF_BACKUPS_TO_KEEP images
echo "Removing older backups"
echo "find $BACKUP_ROOT/$BACKUP_PACKAGE_PREFIX* -maxdepth 0 -type d | sort -r | awk "NR>$NUMBER_OF_BACKUPS_TO_KEEP" | xargs rm -rf"
