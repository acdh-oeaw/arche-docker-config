#!/bin/bash
if [ ! -d /home/www-data/gui/web ]; then
    su -l www-data -c 'composer create-project drupal/recommended-project:8.8.0 /home/www-data/gui --no-interaction --no-install'
    su -l www-data -c "sed -i -e 's|\"drupal-scaffold\" *:.*|\"drupal-scaffold\": {\"allowed-packages\": [\"acdh-oeaw/arche-gui\"],|g' /home/www-data/gui/composer.json"
    su -l www-data -c "cd /home/www-data/gui && composer require drush/drush drupal/bootstrap_mint acdh-oeaw/arche-gui acdh-oeaw/arche-theme drupal/core-composer-scaffold drupal/core-project-message drupal/matomo acdh-oeaw/arche-gui-ontology acdh-oeaw/arche-dashboard  --update-no-dev"
else
    su -l www-data -c 'cd /home/www-data/gui && composer update --no-dev'
fi
if [ ! -L /home/www-data/docroot/browser ]; then
    su -l www-data -c "ln -s /home/www-data/gui/web /home/www-data/docroot/browser"
fi
if [ ! -d /home/www-data/gui/web/modules/contrib/arche-gui/config ]; then
    su -l www-data -c "mkdir -p /home/www-data/gui/web/modules/contrib/arche-gui/config"
fi

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/gui/web/modules/contrib/arche-gui/config/config.yaml $CFGD/config-gui.yaml
su -l www-data -c "$CMD --src $CFGD/schema.yaml --src $CFGD/drupal.yaml --src $CFGD/local.yaml --src $CFGD/repo.yaml --srcPath '$.metadataManagment.nonRelationProperties' --targetPath '$.metadataManagment.nonRelationProperties' $CFGD/config-gui.yaml"
su -l www-data -c "sed -i -e 's/{PG_HOST}/$PG_HOST/g' -e 's/{PG_PORT}/$PG_PORT/g' -e 's/{PG_DBNAME}/$PG_DBNAME/g' -e 's/{PG_USER_PREFIX}/$PG_USER_PREFIX/g' $CFGD/config-gui.yaml"
su -l www-data -c "ln -s $CFGD/config-gui.yaml /home/www-data/gui/web/modules/contrib/arche-gui/config/config.yaml"

