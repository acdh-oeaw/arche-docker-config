#!/bin/bash
echo -e 'zend_extension=xdebug.so\nxdebug.mode=profile\nxdebug.output_dir=/home/www-data/log/xdebug\nxdebug.start_with_request=trigger' | tee /etc/php/*/mods-available/xdebug.ini
su -l www-data -c "mkdir /home/www-data/log/xdebug"
