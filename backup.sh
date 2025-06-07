#!/bin/bash
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
BDIR=/home/www-data/backup
TDIR=/home/www-data/data/tmp
ODIR=/home/www-data/docroot/status
CDIR=`dirname "$BASH_SOURCE[0]"`
FILE="`date +%Y-%m-%d`"
DATEFILE="$BDIR/dateFile"
DOW=`date +%u`
COMPRESSION="none"
COMPRESSIONLEVEL=9
CHUNKSIZEMB=204800 # 200GB

#. "$CDIR/cluster_init.sh"

echo "### Initialization completed, starting a backup on `date +%Y-%m-%dT%H:%M:%S`"

# config dir backup (it's a git repo but can't harm to backup uncommited changes)
cd /home/www-data/ && tar -czf $BDIR/config_$DOW.tgz config && echo "### Config archived successfully"
# always dump the database
echo "### Dumping the database"
$SDIR/backup.php $BDIR/dbdump_$DOW "$CFGFILE" --tmpDir "$TDIR" --include all --compression gzip --compressionLevel 9 --dateFrom 2200-01-01 --dateTo 2200-01-01 2>&1 | tee $BDIR/dbdump_$DOW.log &&\
    echo "### Database dumped successfully"
# full incremental binaries backup on Sunday
if [ "$DOW" == "7" ] ; then
    $SDIR/backup.php --dateFile "$DATEFILE" --chunkSize $CHUNKSIZEMB --compression $COMPRESSION --compressionLevel $COMPRESSIONLEVEL --include none --lock skip --tmpDir "$TDIR" "$BDIR/${FILE}" "$CFGFILE" 2>&1 | tee "$BDIR/${FILE}.log" &&\
    echo "### Incremental binary dump ended successfully" | tee -a "$BDIR/${FILE}.log"
    cp "$BDIR/${FILE}.log" "$ODIR/backup_last.txt"
fi

echo "### Backup ended on `date +%Y-%m-%dT%H:%M:%S`"

# compress logs
echo "### Compressing logs"
$CDIR/run.d/01-logs.sh

echo "### Ended"
