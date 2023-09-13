#!/bin/bash
CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml

rm -f $CFGD/ref-sources-places.yaml
su -l www-data -c "$CMD --src $CFGD/refsources-places.yaml --src $CFGD/local.yaml --srcPath '\$.refsources' $CFGD/config-refsources.yaml"

