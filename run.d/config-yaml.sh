#!/bin/bash
CMD=/home/www-data/docroot/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml

su -l www-data -c "$CMD --src $CFGD/schema.yaml --src $CFGD/uriNorm.yaml --src $CFGD/local.yaml /home/www-data/config/initScripts/config.yaml"
rm -f /home/www-data/docroot/config.yaml
su -l www-data -c "$CMD --src $CFGD/schema.yaml --src $CFGD/repo.yaml --src $CFGD/doorkeeper.yaml --src $CFGD/uriNorm.yaml --src $CFGD/local.yaml /home/www-data/docroot/config.yaml"

