#!/bin/bash
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
BDIR=/home/www-data/backup
TDIR=/home/www-data/data
ODIR=/home/www-data/docroot/status
CDIR=`dirname "$BASH_SOURCE[0]"`
FILE="`date +%Y-%m-%d`."
DATEFILE="$BDIR/dateFile"
DOW=`date +%u`

. "$CDIR/cluster_init.sh"

# config dir backup (it is a git repo but what about uncommited changes)
cd /home/www-data/ && tar -czf $BDIR/config_$DOW.tgz config && echo "--- Config archived successfully"
if [ "$DOW" == "7" ] ; then
    # full incremental binaries backup on Sunday
    $SDIR/backup.php --dateFile "$DATEFILE" --compression gzip --include all --lock skip "$CFGFILE" "$TDIR/${FILE}tgz" 2>&1 | tee "$ODIR/backup_last.txt" &&\
    sha1sum "$TDIR/${FILE}tgz" > "$BDIR/${FILE}tgz.sha1" &&\
    mv "$TDIR/${FILE}tgz" "$BDIR/${FILE}tgz" && echo "--- Incremental binary dump ended successfully" | tee -a "$ODIR/backup_last.txt"
else
    # just a database on other days
    su -l www-data -c "pg_dump -h $HOST -p $PORT -U $USER -n public -T metadata_history $DBNAME" | pv -F '%b ellapsed: %t cur: %r avg: %a' | gzip -9 -c > $BDIR/dbdump_$DOW.sql.gz && echo "--- Database dumped successfully"
fi

# compress logs
echo "--- Compressing logs"
$CDIR/run.d/01-logs.sh
