#!/bin/bash
echo -e 'zend_extension=xdebug.so\nxdebug.mode=coverage' | tee /etc/php/*/*/conf.d/20-xdebug.ini
