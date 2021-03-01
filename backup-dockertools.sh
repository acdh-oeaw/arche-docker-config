#!/bin/bash
mkdir -p /home/www-data/backup/docker-tools/
if [ "`id -u`" == "0" ]; then
    su -l www-data -c "pg_dump -n public -T full_text_search" | gzip -9 -c > /home/www-data/backup/docker-tools/dbdump.sql.gz
else
    pg_dump -n public -T full_text_search | gzip -9 -c > /home/www-data/backup/docker-tools/dbdump.sql.gz
fi
cd /home/www-data/ && tar -czf /home/www-data/backup/docker-tools/config.tgz config

