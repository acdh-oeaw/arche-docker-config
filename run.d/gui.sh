#!/bin/bash
if [ ! -d /home/www-data/gui/web ]; then
    su -l www-data -c 'composer create-project drupal/recommended-project:^9 /home/www-data/gui/tmp --no-interaction --no-install'
    su -l www-data -c 'mv /home/www-data/gui/tmp/* /home/www-data/gui/ && rmdir /home/www-data/gui/tmp'
    su -l www-data -c "sed -i -e 's|\"drupal-scaffold\" *:.*|\"drupal-scaffold\": {\"allowed-packages\": [\"acdh-oeaw/arche-gui\"],|g' /home/www-data/gui/composer.json"
    su -l www-data -c "cd /home/www-data/gui && composer require drush/drush acdh-oeaw/arche-gui acdh-oeaw/arche-gui-api acdh-oeaw/arche-mde-api acdh-oeaw/arche-theme acdh-oeaw/arche-gui-ontology acdh-oeaw/arche-dashboard composer/installers drupal/core-composer-scaffold drupal/core-project-message drupal/core-recommended drupal/devel drupal/devel_entity_updates drupal/restui drupal/matomo --update-no-dev && composer dump-autoload -o"
else
    su -l www-data -c 'cd /home/www-data/gui && composer update --no-dev -o'
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

