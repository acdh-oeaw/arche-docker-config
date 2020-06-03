#!/bin/bash
CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml

if [ ! -f $CFGD/local.yaml ]; then
  echo "$CFGD/local.yaml provided - using $CFGD/local.yaml.sample instead"
  su -l www-data -c "cp $CFGD/local.yaml.sample $CFGD/local.yaml"
fi
rm -f /home/www-data/config/initScripts/config.yaml
su -l www-data -c "$CMD --src $CFGD/schema.yaml --src $CFGD/uriNorm.yaml --src $CFGD/local.yaml /home/www-data/config/initScripts/config.yaml"

rm -f /home/www-data/docroot/api/config.yaml $CFGD/config-repo.yaml
su -l www-data -c "$CMD --src $CFGD/schema.yaml --src $CFGD/repo.yaml --src $CFGD/doorkeeper.yaml --src $CFGD/uriNorm.yaml --srcPath '$.schema.uriNorm' --targetPath '$.doorkeeper.uriNorm' --src $CFGD/local.yaml $CFGD/config-repo.yaml"
su -l www-data -c "sed -i -e 's/{PG_HOST}/$PG_HOST/g' -e 's/{PG_PORT}/$PG_PORT/g' -e 's/{PG_DBNAME}/$PG_DBNAME/g' -e 's/{PG_USER_PREFIX}/$PG_USER_PREFIX/g' $CFGD/config-repo.yaml"
su -l www-data -c "ln -s $CFGD/config-repo.yaml /home/www-data/docroot/api/config.yaml"

