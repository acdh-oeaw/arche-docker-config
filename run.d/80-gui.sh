#!/bin/bash
if [ ! -d /home/www-data/gui/web ]; then
    su -l www-data -c 'composer create-project drupal/recommended-project:^10 /home/www-data/gui/tmp --no-interaction --no-install'
    su -l www-data -c 'mv /home/www-data/gui/tmp/* /home/www-data/gui/ && rmdir /home/www-data/gui/tmp'
    su -l www-data -c "sed -i -e 's|\"drupal-scaffold\" *:.*|\"drupal-scaffold\": {\"allowed-packages\": [\"acdh-oeaw/arche_core_gui\",\"acdh-oeaw/arche-theme-bs\" ],|g' /home/www-data/gui/composer.json"
    su -l www-data -c "cd /home/www-data/gui && composer require drush/drush acdh-oeaw/arche_core_gui acdh-oeaw/arche_core_gui_api acdh-oeaw/arche-theme-bs composer/installers drupal/core-composer-scaffold drupal/core-project-message drupal/core-recommended drupal/devel drupal/devel_entity_updates drupal/entity_clone:2.1.0-beta1 drupal/restui drupal/matomo --update-no-dev && composer dump-autoload -o"
else
    su -l www-data -c 'cd /home/www-data/gui && composer update --no-dev -o'
fi
if [ ! -L /home/www-data/docroot/browser ]; then
    su -l www-data -c "ln -s /home/www-data/gui/web /home/www-data/docroot/browser"
fi
if [ ! -d /home/www-data/gui/web/modules/contrib/arche_core_gui/config ]; then
    su -l www-data -c "mkdir -p /home/www-data/gui/web/modules/contrib/arche_core_gui/config"
fi

sed -i -e "s/%GUI_DB_DBNAME%/$GUI_DB_NAME/g" -e "s/%GUI_DB_USERNAME%/$GUI_DB_USER/g" -e "s/%GUI_DB_PASSWORD%/$GUI_DB_PSWD/g" -e "s/%GUI_DB_HOST%/$GUI_DB_HOST/g" -e "s/%GUI_DB_PORT%/$GUI_DB_PORT/g" /home/www-data/gui/web/sites/default/settings.php

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/gui/web/modules/contrib/arche_core_gui/config/config.yaml $CFGD/config-gui.yaml
su -l www-data -c "$CMD \\
    --src $CFGD/schema.yaml \\
    --src $CFGD/openaire.yaml \\
    --src $CFGD/drupal.yaml \\
    --src $CFGD/smartSearch.yaml \\
    --src $CFGD/repo.yaml --srcPath '$.metadataManagment.nonRelationProperties' --targetPath '$.metadataManagment.nonRelationProperties' \\
    --src $CFGD/db.yaml --srcPath '$.dbConnStr.gui' --targetPath '$.dbConnStr' \\
    --src $CFGD/local.yaml \\
    $CFGD/config-gui.yaml"
su -l www-data -c "sed -i -e 's/{PG_HOST}/$PG_HOST/g' -e 's/{PG_PORT}/$PG_PORT/g' -e 's/{PG_DBNAME}/$PG_DBNAME/g' -e 's/{PG_USER_PREFIX}/$PG_USER_PREFIX/g' $CFGD/config-gui.yaml"
su -l www-data -c "ln -s $CFGD/config-gui.yaml /home/www-data/gui/web/modules/contrib/arche_core_gui/config/config.yaml"

