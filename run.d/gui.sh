#!/bin/bash
if [ ! -d /home/www-data/vendor/_gui ]; then
    su -l www-data -c 'mkdir /home/www-data/vendor/_gui'
fi
if [ ! -d /home/www-data/docroot/browser ]; then
    su -l www-data -c 'composer create-project drupal/recommended-project /home/www-data/docroot/browser --no-interaction --no-install'
    su -l www-data -c 'ln -s /home/www-data/vendor/_gui/ /home/www-data/docroot/browser/vendor'
    su -l www-data -c "sed -i -e 's|\"web-root\" *:.*|\"web-root\": \"./\"|g' -e 's|\"drupal-scaffold\" *:.*|\"drupal-scaffold\": {\"allowed-packages\": [\"acdh-oeaw/arche-gui\"],|g' /home/www-data/docroot/browser/composer.json"
    su -l www-data -c "cd /home/www-data/docroot/browser && composer require drush/drush drupal/bootstrap_mint acdh-oeaw/arche-gui --update-no-dev"
    su -l www-data -c "mkdir -p /home/www-data/docroot/browser/web/modules/contrib/arche-gui/config"
else
    su -l www-data -c 'cd /home/www-data/docroot/browser && composer update --no-dev'
fi

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/docroot/browser/web/modules/contrib/arche-gui/config/config.yaml $CFGD/config-gui.yaml
su -l www-data -c "$CMD --src $CFGD/schema.yaml --src $CFGD/drupal.yaml --src $CFGD/local.yaml --src $CFGD/repo.yaml --srcPath '$.metadataManagment.nonRelationProperties' --targetPath '$.metadataManagment.nonRelationProperties' $CFGD/config-gui.yaml"
su -l www-data -c "ln -s $CFGD/config-gui.yaml /home/www-data/docroot/browser/web/modules/contrib/arche-gui/config/config.yaml"

