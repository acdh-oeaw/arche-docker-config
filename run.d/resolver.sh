#!/bin/bash
if [ ! -d /home/www-data/docroot/resolver ]; then
    su -l www-data -c 'mkdir /home/www-data/docroot/resolver'
    su -l www-data -c 'ln -s ../vendor /home/www-data/docroot/resolver/vendor'
fi
su -l www-data -c 'cp /home/www-data/docroot/vendor/acdh-oeaw/arche-resolver/.htaccess /home/www-data/docroot/resolver/.htaccess'
su -l www-data -c 'cp /home/www-data/docroot/vendor/acdh-oeaw/arche-resolver/index.php /home/www-data/docroot/resolver/index.php'

CMD=/home/www-data/docroot/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/docroot/resolver/config.yaml
su -l www-data -c "$CMD --src $CFGD/schema.yaml --src $CFGD/resolver.yaml --src $CFGD/local.yaml /home/www-data/docroot/resolver/config.yaml"

