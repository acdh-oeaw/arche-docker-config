#!/bin/bash
if [ ! -d /home/www-data/docroot/openrefine ]; then
    su -l www-data -c 'mkdir /home/www-data/docroot/openrefine'
    su -l www-data -c 'ln -s /home/www-data/vendor /home/www-data/docroot/openrefine/vendor'
fi
su -l www-data -c 'cp /home/www-data/vendor/acdh-oeaw/arche-openrefine/.htaccess /home/www-data/docroot/openrefine/.htaccess'
su -l www-data -c 'cp /home/www-data/vendor/acdh-oeaw/arche-openrefine/index.php /home/www-data/docroot/openrefine/index.php'

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/docroot/openrefine/config.yaml $CFGD/config-openrefine.yaml
su -l www-data -c "$CMD \\
    --src $CFGD/schema.yaml \\
    --src $CFGD/openrefine.yaml \\
    --src $CFGD/db.yaml --srcPath '$.dbConnStr.guest' --targetPath '$.dbConnStr' \\
    --src $CFGD/local.yaml --srcPath '$.openrefine' \\
    $CFGD/config-openrefine.yaml"
su -l www-data -c "ln -s $CFGD/config-openrefine.yaml /home/www-data/docroot/openrefine/config.yaml"

