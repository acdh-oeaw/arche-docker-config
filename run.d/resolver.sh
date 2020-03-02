#!/bin/bash
if [ ! -d /home/www-data/docroot/resolver ]; then
    su -l www-data -c 'mkdir /home/www-data/docroot/resolver'
    su -l www-data -c 'ln -s ../vendor /home/www-data/docroot/resolver/vendor'
    su -l www-data -c 'ln -s ../config.yaml /home/www-data/docroot/resolver/config.yaml'
fi
su -l www-data -c 'cp /home/www-data/docroot/vendor/acdh-oeaw/acdh-repo-resolver/.htaccess /home/www-data/docroot/resolver/.htaccess'
su -l www-data -c 'cp /home/www-data/docroot/vendor/acdh-oeaw/acdh-repo-resolver/index.php /home/www-data/docroot/resolver/index.php'

