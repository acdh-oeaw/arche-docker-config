#!/bin/bash

# change php's upload_tmp_dir
# (it can't be done trough Apache config php_value directive)
sed -i -E 's/^;? *upload_tmp_dir.*/upload_tmp_dir = \/home\/www-data\/tmp/g' /etc/php/*/*/php.ini

