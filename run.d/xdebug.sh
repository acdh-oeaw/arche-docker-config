#!/bin/bash
echo -e 'zend_extension=xdebug.so\nxdebug.mode=coverage' | tee /etc/php/*/mods-available/xdebug.ini
