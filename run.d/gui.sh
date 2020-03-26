#!/bin/bash
if [ ! -d /home/www-data/gui/web ]; then
    su -l www-data -c 'composer create-project drupal/recommended-project /home/www-data/gui --no-interaction --no-install'
    su -l www-data -c "sed -i -e 's|\"drupal-scaffold\" *:.*|\"drupal-scaffold\": {\"allowed-packages\": [\"acdh-oeaw/arche-gui\"],|g' /home/www-data/gui/composer.json"
    su -l www-data -c "cd /home/www-data/gui && composer require drush/drush drupal/bootstrap_mint acdh-oeaw/arche-gui acdh-oeaw/arche-theme --update-no-dev"
    su -l www-data -c "mkdir -p /home/www-data/gui/web/modules/contrib/arche-gui/config"
    su -l www-data -c "ln -s /home/www-data/gui/web /home/www-data/docroot/browser"
else
    su -l www-data -c 'cd /home/www-data/gui && composer update --no-dev'
fi

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/gui/web/modules/contrib/arche-gui/config/config.yaml $CFGD/config-gui.yaml
su -l www-data -c "$CMD --src $CFGD/schema.yaml --src $CFGD/drupal.yaml --src $CFGD/local.yaml --src $CFGD/repo.yaml --srcPath '$.metadataManagment.nonRelationProperties' --targetPath '$.metadataManagment.nonRelationProperties' $CFGD/config-gui.yaml"
su -l www-data -c "ln -s $CFGD/config-gui.yaml /home/www-data/gui/web/modules/contrib/arche-gui/config/config.yaml"

