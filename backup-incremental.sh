#!/bin/bash
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
BDIR=/home/www-data/backup
BACKUP_FILE="$BDIR/`date +%Y-%m-%d`."

$SDIR/backup.php --dateFile $BDIR/dateFile --compression gzip --include skipSearch --lock skip /home/www-data/docroot/api/config.yaml ${BACKUP_FILE}tgz > ${BACKUP_FILE}log 2>&1
sha1sum ${BACKUP_FILE}tgz > ${BACKUP_FILE}tgz.sha1
