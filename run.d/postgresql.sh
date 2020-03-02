#!/bin/bash
if [ ! -f /home/www-data/postgresql/postgresql.conf ]; then
    su -l www-data -c '/usr/lib/postgresql/11/bin/initdb -D /home/www-data/postgresql --auth=ident -U www-data --locale en_US.UTF-8'
    su -l www-data -c '/usr/lib/postgresql/11/bin/pg_ctl start -D /home/www-data/postgresql -l /home/www-data/log/postgresql.log'
    su -l www-data -c '/usr/bin/createdb www-data'
    su -l www-data -c '/usr/bin/psql -f /home/www-data/docroot/vendor/acdh-oeaw/acdh-repo/build/db_schema.sql'
    su -l www-data -c '/usr/bin/createuser repo'
    su -l www-data -c '/usr/bin/createuser guest'
    su -l www-data -c 'echo "GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO guest; GRANT USAGE ON SCHEMA public TO guest" | /usr/bin/psql'
    su -l www-data -c 'echo "GRANT SELECT, INSERT, DELETE, UPDATE, TRUNCATE ON ALL TABLES IN SCHEMA PUBLIC TO repo; GRANT USAGE ON SCHEMA public TO repo" | /usr/bin/psql'
    su -l www-data -c '/usr/lib/postgresql/11/bin/pg_ctl stop -D /home/www-data/postgresql'
fi
rm -f /home/www-data/postgresql/postmaster.pid /var/run/postgresql/.s.PGSQL.5432.lock

