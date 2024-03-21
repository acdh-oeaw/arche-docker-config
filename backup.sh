#!/bin/bash
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
BDIR=/home/www-data/backup
TDIR=/home/www-data/data
ODIR=/home/www-data/docroot/status
FILE="`date +%Y-%m-%d`."
DATEFILE="$BDIR/dateFile"

if [ -f /home/www-data/composer.json ] ; then
    echo "This script should not be run on initialized ARCHE container"
    exit 1
fi

ln -s /home/www-data/config/composer.json /home/www-data/composer.json
cd /home/www-data && su -l www-data -c 'composer update -o --no-dev' || exit 2

cp /home/www-data/config/backup_pgpass /home/www-data/.pgpass &&\
  cp /home/www-data/.pgpass /root/.pgpass &&\
  chmod 600 /home/www-data/.pgpass /root/.pgpass &&\
  chown www-data:www-data /home/www-data/.pgpass
IFS=: read HOST PORT DBNAME USER PSWD < /home/www-data/.pgpass

DOW=`date +%u`
cd /home/www-data/ && tar -czf $BDIR/config_$DOW.tgz config && echo "Config archived successfully"
if [ "$DOW" == "4" ] ; then
    /home/www-data/vendor/bin/yaml-edit.php \
        --src "{\"dbConnStr\": {\"backup\": \"pgsql: host=$HOST port=$PORT user=$USER dbname=$DBNAME\"}}" \
        --src /home/www-data/config/yaml/config-repo.yaml --srcPath $.schema --targetPath $.schema \
        --src /home/www-data/config/yaml/config-repo.yaml --srcPath $.storage --targetPath $.storage \
        /tmp/config-backup.yaml &&\
      $SDIR/backup.php --dateFile "$DATEFILE" --compression gzip --include all --lock skip /tmp/config-backup.yaml "$TDIR/${FILE}tgz" 2>&1 | tee "$ODIR/backup_last.txt" &&\
      sha1sum "$TDIR/${FILE}tgz" > "$BDIR/${FILE}tgz.sha1" &&\
      mv "$TDIR/${FILE}tgz" "$BDIR/${FILE}tgz" && echo "Incremental binary dump ended successfully" | tee -a "$ODIR/backup_last.txt"
else
    su -l www-data -c "pg_dump -h $HOST -p $PORT -U $USER -n public -T metadata_history $DBNAME" | pv -F '%b ellapsed: %t cur: %r avg: %a' | gzip -9 -c > $BDIR/dbdump_$DOW.sql.gz && echo "Database dumped successfully"
fi

