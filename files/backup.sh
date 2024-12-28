#!/bin/bash
# example: 
# 0 1 * * * /bin/bash -lc "/home/webadmin/backup/backup.sh > /home/webadmin/backup/backup.log"

ROTATE_DAYS=2
BACKUP_DIR='/home/webadmin/backup/storage'

HOME_DIR='/home/webadmin/web'

DB_NAMES=($(mysqlshow | sed -E 's/[|,+,-]|\s|\t//g' | tail -n+4 | head -n-1))
DB_EXCLUDE=("information_schema" "mysql" "performance_schema" "sys")

DT_STRING=$(date +%Y%m%d_%H%M%S)

function is_exists() {
  elem="$1"
  shift
  elem_array=("$@")
  for i in "${elem_array[@]}" ; do
    if [ "$i" == "$elem" ] ; then
      return 0
    fi
  done
  return 1
}

echo "Starting backup at $DT_STRING!"

#Backup and compress home dir
echo "Backup home directory..."
tar -zcvf $BACKUP_DIR/home_$DT_STRING.tar.gz -C $HOME_DIR .

#Backup and compress db
for d in "${DB_NAMES[@]}" ; do
  if ! is_exists "$d" "${DB_EXCLUDE[@]}" ; then
          echo "Backup database $d..."
          mysqldump --single-transaction --routines $d | gzip > $BACKUP_DIR/db_$d-$DT_STRING.gz
  else
    echo "Skipping db $d"
  fi
done

#Remove files older rotation period
echo "Cleaning-up old backups..."
find -O3 $BACKUP_DIR -type f -mtime +$ROTATE_DAYS -name *.gz -delete

echo "Backup at $DT_STRING complete!"
