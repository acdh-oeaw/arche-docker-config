#!/bin/bash
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
BDIR=/home/www-data/backup
TDIR=/home/www-data/data
ODIR=/home/www-data/docroot/status
FILE="`date +%Y-%m-%d`."
DATEFILE="$BDIR/dateFile"

if [ "`id -u`" == "0" ]; then
    # if the script is run as root, normal user lacks priviledges for writing to the $BDIR
    DATEFILE="$TDIR/dateFile"
    cp "$BDIR/dateFile" "$DATEFILE"
    chown www-data:www-data "$DATEFILE"
fi
su -l www-data -c "$SDIR/backup.php --dateFile '$DATEFILE' --compression gzip --include all --lock skip /home/www-data/docroot/api/config.yaml '$TDIR/${FILE}tgz'" > "$BDIR/${FILE}log" 2>&1
su -l www-data -c "mkdir -p $ODIR"
su -l www-data -c "cp '$BDIR/${FILE}log' '$ODIR/backup_last.log'"
if [ "`id -u`" == "0" ]; then
    cp "$DATEFILE" "$BDIR/dateFile"
    rm "$DATEFILE"
fi
sha1sum "$TDIR/${FILE}tgz" > "$BDIR/${FILE}tgz.sha1"
mv "$TDIR/${FILE}tgz" "$BDIR/${FILE}tgz"

