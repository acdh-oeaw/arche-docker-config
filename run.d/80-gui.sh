#!/bin/bash

GUIDIR=/home/www-data/gui
if [ ! -d /home/www-data/gui/.git ]; then
    rm -fR $GUIDIR/* $GUISIR/.* &&\
        su -w http_proxy,https_proxy -l www-data -c "git clone https://github.com/nczirjak-acdh/arche-gui-backend-api.git $GUIDIR" || exit 1
fi
#sed -i -e '/cache:clear/d' -e '/assets:install/d' $GUIDIR/composer.json
su -l www-data -w http_proxy,https_proxy -c 'cd /home/www-data/gui && composer install --no-dev --no-interaction --optimize-autoloader' || exit 1

su -l www-data -c "ln -sf /home/www-data/gui/public /home/www-data/docroot/guiApi"

echo "Creating /home/www-data/gui/.env"
echo "APP_SHARE_DIR=var/share" >> /home/www-data/gui/.env
echo "DB_HOST='$GUI_DB_HOST'" >> /home/www-data/gui/.env
echo "DB_PORT='$GUI_DB_PORT'" >> /home/www-data/gui/.env
echo "DB_USER='$GUI_DB_USER'" >> /home/www-data/gui/.env
echo "DB_NAME='$GUI_DB_NAME'" >> /home/www-data/gui/.env
echo "APP_ENV=$APP_ENV"           >> /home/www-data/gui/.env
echo "APP_DEBUG=$APP_DEBUG"       >> /home/www-data/gui/.env
echo "APP_SECRET='$APP_SECRET'"   >> /home/www-data/gui/.env
echo "DEFAULT_URI='$DEFAULT_URI'" >> /home/www-data/gui/.env
echo "CORS_ALLOW_ORIGIN='$CORS_ALLOW_ORIGIN'" >> /home/www-data/gui/.env

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
echo "Creating $CFGD/config-gui.yaml"
rm -f /home/www-data/gui/src/arche-config/config-gui.yaml $CFGD/config-gui.yaml
su -l www-data -c "$CMD \\
    --src $CFGD/schema.yaml \\
    --src $CFGD/openaire.yaml \\
    --src $CFGD/smartSearch.yaml \\
    --src $CFGD/repo.yaml --srcPath '$.metadataManagment.nonRelationProperties' --targetPath '$.metadataManagment.nonRelationProperties' \\
    --src $CFGD/repo.yaml --srcPath '$.accessControl.publicRole' --targetPath '$.publicRole' \\
    --src $CFGD/config-db.yaml --srcPath '$.dbConnStr.gui' --targetPath '$.dbConnStr' \\
    --src $CFGD/local.yaml \\
    $CFGD/config-gui.yaml"
su -l www-data -c "ln -s $CFGD/config-gui.yaml /home/www-data/gui/src/arche-config/config-gui.yaml"

