#!/bin/bash

# cleanup faulty shutdowns
rm -f /home/www-data/postgresql/postmaster.pid /var/run/postgresql/.s.PGSQL.5432.lock

# initialize database
if [ ! -f /home/www-data/postgresql/postgresql.conf ]; then
    su -l www-data -c '/usr/lib/postgresql/11/bin/initdb -D /home/www-data/postgresql --auth=ident -U www-data --locale en_US.UTF-8'
    sed -i -E 's/^(host.*ident)$/#\1/g' /home/www-data/postgresql/pg_hba.conf
    echo "host    all             all             127.0.0.1/32            md5" >> /home/www-data/postgresql/pg_hba.conf
    su -l www-data -c '/usr/lib/postgresql/11/bin/pg_ctl start -D /home/www-data/postgresql -l /home/www-data/log/postgresql.log'
    su -l www-data -c '/usr/bin/createdb www-data'
    su -l www-data -c '/usr/bin/psql -f /home/www-data/docroot/vendor/acdh-oeaw/arche-core/build/db_schema.sql'
    su -l www-data -c '/usr/bin/createuser repo'
    su -l www-data -c '/usr/bin/createuser guest'
else
    su -l www-data -c '/usr/lib/postgresql/11/bin/pg_ctl start -D /home/www-data/postgresql -l /home/www-data/log/postgresql.log'
fi

# assure not-superuser user rights
su -l www-data -c 'echo "GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO guest; GRANT USAGE ON SCHEMA public TO guest" | /usr/bin/psql'
su -l www-data -c 'echo "GRANT SELECT, INSERT, DELETE, UPDATE, TRUNCATE ON ALL TABLES IN SCHEMA public TO repo; GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO repo; GRANT USAGE ON SCHEMA public TO repo" | /usr/bin/psql'

# set random passwords for guest and repo users and store them in /home/www-data/.pgpass
su -l www-data -c 'echo "" > /home/www-data/.pgpass && chmod 600 /home/www-data/.pgpass'
for user in repo guest; do
    PSWD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32}`
    su -l www-data -c "echo \"ALTER USER $user WITH password '$PSWD'\" | /usr/bin/psql"
    echo "*:*:*:$user:$PSWD" >> /home/www-data/.pgpass
done
PSWD=""

su -l www-data -c '/usr/lib/postgresql/11/bin/pg_ctl stop -D /home/www-data/postgresql'

