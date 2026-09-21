#!/bin/bash
if [ ! -d /home/www-data/gui/.git ]; then
    su -w http_proxy,https_proxy -l www-data -c 'git clone https://github.com/nczirjak-acdh/arche-gui-backend-api.git /home/www-data/gui' || exit 1
fi
su -w http_proxy,https_proxy -l www-data -c 'cd /home/www-data/gui && APP_ENV=prod APP_DEBUG=0 composer install --no-dev --no-interaction --optimize-autoloader' || exit 1
su -l www-data -c "ln -sfn /home/www-data/gui/public /home/www-data/docroot/browser"

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/gui/src/arche-config/config-gui.yaml $CFGD/config-gui.yaml
su -l www-data -c "$CMD \\
    --src $CFGD/schema.yaml \\
    --src $CFGD/openaire.yaml \\
    --src $CFGD/drupal.yaml \\
    --src $CFGD/smartSearch.yaml \\
    --src $CFGD/repo.yaml --srcPath '$.metadataManagment.nonRelationProperties' --targetPath '$.metadataManagment.nonRelationProperties' \\
    --src $CFGD/repo.yaml --srcPath '$.accessControl.publicRole' --targetPath '$.publicRole' \\
    --src $CFGD/config-db.yaml --srcPath '$.dbConnStr.gui' --targetPath '$.dbConnStr' \\
    --src $CFGD/local.yaml \\
    $CFGD/config-gui.yaml"
su -l www-data -c "ln -s $CFGD/config-gui.yaml /home/www-data/gui/src/arche-config/config-gui.yaml"
