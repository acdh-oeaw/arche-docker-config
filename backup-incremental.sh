#!/bin/bash
/home/www-data/vendor/acdh-oeaw/arche-core/backup.php --dateFile /home/www-data/backup/dateFile --compression gzip --include skipSearch --lock skip /home/www-data/docroot/api/config.yaml /home/www-data/backup/`date +%Y-%m-%d`.gzip > /home/www-data/backup/`date +%Y-%m-%d`.log 2>&1
