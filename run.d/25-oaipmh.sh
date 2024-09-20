#!/bin/bash
if [ ! -d /home/www-data/docroot/oaipmh ]; then
    su -l www-data -c 'mkdir /home/www-data/docroot/oaipmh'
    su -l www-data -c 'ln -s /home/www-data/vendor /home/www-data/docroot/oaipmh/vendor'
fi
su -l www-data -c 'cp /home/www-data/vendor/acdh-oeaw/arche-oaipmh/.htaccess /home/www-data/docroot/oaipmh/.htaccess'
su -l www-data -c 'cp /home/www-data/vendor/acdh-oeaw/arche-oaipmh/index.php /home/www-data/docroot/oaipmh/index.php'

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/docroot/oaipmh/config.yaml $CFGD/config-oaipmh.yaml
su -l www-data -c "$CMD \\
    --src $CFGD/oaipmh.yaml \\
    --src $CFGD/config-db.yaml --srcPath '$.dbConnStr.guest' --targetPath '$.oai.dbConnStr' \\
    --src $CFGD/local.yaml --srcPath '$.oai' --targetPath '$.oai' \\
    $CFGD/config-oaipmh.yaml"
su -l www-data -c "ln -s $CFGD/config-oaipmh.yaml /home/www-data/docroot/oaipmh/config.yaml"

