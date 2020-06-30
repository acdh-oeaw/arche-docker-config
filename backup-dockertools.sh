#!/bin/bash
mkdir -p /home/www-data/backup/docker-tools/
pg_dump -n public -T full_text_search | gzip -9 -c > /home/www-data/backup/docker-tools/dbdump.sql.gz
cd /home/www-data/ && tar -czf /home/www-data/backup/docker-tools/config.tgz config

