#!/bin/bash
# Initializes a plain acdhch/arche container so it can be used for ARCHE-related cron jobs

if [ -f /home/www-data/composer.json ] ; then
    echo "This script should not be run on initialized ARCHE container"
    exit 1
fi

# install composer-managed libraries
ln -s /home/www-data/config/composer.json /home/www-data/composer.json
cd /home/www-data && su -l www-data -c 'composer update -o --no-dev' || exit 2

# set up pgpass files for www-data and root users based on the pgpass file in the config dir
cp /home/www-data/config/backup_pgpass /home/www-data/.pgpass &&\
  cp /home/www-data/.pgpass /root/.pgpass &&\
  chmod 600 /home/www-data/.pgpass /root/.pgpass &&\
  chown www-data:www-data /home/www-data/.pgpass

# set db connection variables
IFS=: read HOST PORT DBNAME USER PSWD < /home/www-data/.pgpass || exit 3
DBCONN="pgsql: host=$HOST port=$PORT user=$USER dbname=$DBNAME"

# prepare config.yaml for the {arche-core}/backup.php, {arche-core}/checkHashes.php 
# and {arche-core}/cleanupStorage.php scripts
CFGFILE=/tmp/config.yaml
/home/www-data/vendor/bin/yaml-edit.php \
    --src "{\"dbConnStr\": {\"backup\": \"$DBCONN\", \"guest\": \"$DBCONN\"}}" \
    --src /home/www-data/config/yaml/config-repo.yaml --srcPath $.schema --targetPath $.schema \
    --src /home/www-data/config/yaml/config-repo.yaml --srcPath $.storage --targetPath $.storage \
    "$CFGFILE" 2>&1 || exit 4
