#!/bin/bash
if [ ! -d /home/www-data/docroot/resolver ]; then
    su -l www-data -c 'mkdir /home/www-data/docroot/resolver'
    su -l www-data -c 'ln -s /home/www-data/vendor /home/www-data/docroot/resolver/vendor'
fi
su -l www-data -c 'cp /home/www-data/vendor/acdh-oeaw/arche-resolver/.htaccess /home/www-data/docroot/resolver/.htaccess'
su -l www-data -c 'cp /home/www-data/vendor/acdh-oeaw/arche-resolver/index.php /home/www-data/docroot/resolver/index.php'

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/docroot/resolver/config.yaml $CFGD/config-resolver.yaml
su -l www-data -c "$CMD \\
    --src $CFGD/schema.yaml \\
    --src $CFGD/resolver.yaml \\
    --src $CFGD/db.yaml --srcPath '$.dbConnStr.guest' --targetPath '$.resolver.repositories.self.dbConnStr' \\
    --src $CFGD/local.yaml \\
    $CFGD/config-resolver.yaml"
su -l www-data -c "ln -s $CFGD/config-resolver.yaml /home/www-data/docroot/resolver/config.yaml"

