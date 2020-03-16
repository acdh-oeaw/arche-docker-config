#!/bin/bash
if [ ! -d /home/www-data/oaipmh ]; then
    su -l www-data -c 'mkdir /home/www-data/oaipmh'
    su -l www-data -c 'ln -s /home/www-data/docroot/vendor /home/www-data/oaipmh/vendor'
fi
su -l www-data -c 'cp /home/www-data/docroot/vendor/acdh-oeaw/arche-oaipmh/.htaccess /home/www-data/oaipmh/.htaccess'
su -l www-data -c 'cp /home/www-data/docroot/vendor/acdh-oeaw/arche-oaipmh/index.php /home/www-data/oaipmh/index.php'

CMD=/home/www-data/docroot/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/oaipmh/config.yaml
su -l www-data -c "$CMD --src $CFGD/oaipmh.yaml --src $CFGD/local.yaml /home/www-data/oaipmh/config.yaml"

