#!/bin/bash
# $USER_* variables are set by the 10-postgresql.sh which has to run first!

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml

if [ ! -f $CFGD/local.yaml ]; then
  echo "$CFGD/local.yaml provided - using $CFGD/local.yaml.sample instead"
  su -l www-data -c "cp $CFGD/local.yaml.sample $CFGD/local.yaml"
fi
rm -f /home/www-data/config/initScripts/config.yaml
su -l www-data -c "$CMD --src $CFGD/schema.yaml --src $CFGD/local.yaml /home/www-data/config/initScripts/config.yaml"

rm -f /home/www-data/docroot/api/config.yaml $CFGD/config-repo.yaml
su -l www-data -c "$CMD \\
    --src $CFGD/schema.yaml \\
    --src $CFGD/repo.yaml \\
    --src $CFGD/doorkeeper.yaml \\
    --src $CFGD/openaire.yaml \\
    --src $CFGD/db.yaml --srcPath '$.dbConnStr.repo' --targetPath '$.dbConn.admin' \\
    --src $CFGD/db.yaml --srcPath '$.dbConnStr.repo' --targetPath '$.dbConnStr.admin' \\
    --src $CFGD/db.yaml --srcPath '$.dbConnStr.repo' --targetPath '$.accessControl.db.connStr' \\
    --src $CFGD/db.yaml --srcPath '$.dbConnStr.guest' --targetPath '$.dbConn.guest' \\
    --src $CFGD/db.yaml --srcPath '$.dbConnStr.guest' --targetPath '$.dbConnStr.guest' \\
    --src $CFGD/local.yaml \\
    $CFGD/config-repo.yaml"
su -l www-data -c "ln -s $CFGD/config-repo.yaml /home/www-data/docroot/api/config.yaml"

