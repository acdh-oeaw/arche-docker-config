#!/bin/bash
if [ ! -d /home/www-data/docroot/oaipmh ]; then
    su -l www-data -c 'mkdir /home/www-data/oaipmh'
    su -l www-data -c 'ln -s /home/www-data/docroot/vendor /home/www-data/oaipmh/vendor'
    su -l www-data -c 'ln -s /home/www-data/config/config-oaipmh.yaml /home/www-data/oaipmh/config.yaml'
fi
su -l www-data -c 'cp /home/www-data/docroot/vendor/acdh-oeaw/acdh-repo-oaipmh/.htaccess /home/www-data/oaipmh/.htaccess'
su -l www-data -c 'cp /home/www-data/docroot/vendor/acdh-oeaw/acdh-repo-oaipmh/index.php /home/www-data/oaipmh/index.php'

