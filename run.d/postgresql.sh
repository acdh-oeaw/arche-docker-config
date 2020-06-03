#!/bin/bash

# cleanup the .pgpass file
su -l www-data -c 'echo "" > /home/www-data/.pgpass && chmod 600 /home/www-data/.pgpass'
# cleanup faulty shutdowns
rm -f /home/www-data/postgresql/postmaster.pid /var/run/postgresql/.s.PGSQL.5432.lock

PG_CONN=""
if [ ! -e "$PG_HOST" ]; then
    PG_PORT=${PG_PORT:=5432}
    PG_USER=${PG_USER:=postgres}
    PG_DBNAME=${PG_DBNAME:=postgres}

    echo "$PG_HOST:$PG_PORT:$PG_DBNAME:$PG_USER:PG_PSWD" >> /home/www-data/.pgpass

    PG_CONN="-h '$PG_HOST' -p $PG_PORT -U '$PG_USER'"
    echo "CREATE DATABASE $PG_DBNAME" | /usr/bin/psql $PG_CONN

    PG_CONN="-h '$PG_HOST' -p $PG_PORT -U '$PG_USER' '$PG_DBNAME'"
    echo "CREATE USER ${PG_USERPREFIX}repo; CREATE USER ${PG_USERPREFIX}guest; CREATE USER ${PG_USERPREFIX}gui" | /usr/bin/psql $PG_CONN
    echo "CREATE SCHEMA gui AUTHORIZATION gui" | /usr/bin/psql $PG_CONN
else
    if [ ! -f /home/www-data/postgresql/postgresql.conf ]; then
        # initialize local database cluster
        su -l www-data -c '/usr/lib/postgresql/12/bin/initdb -D /home/www-data/postgresql --auth=ident -U www-data --locale en_US.UTF-8'
        sed -i -E 's/^(host.*ident)$/#\1/g' /home/www-data/postgresql/pg_hba.conf
        echo "host    all             all             127.0.0.1/32            md5" >> /home/www-data/postgresql/pg_hba.conf
        su -l www-data -c '/usr/lib/postgresql/12/bin/pg_ctl start -D /home/www-data/postgresql -l /home/www-data/log/postgresql.log'
        su -l www-data -c '/usr/bin/createdb www-data'
        su -l www-data -c '/usr/bin/psql -f /home/www-data/vendor/acdh-oeaw/arche-core/build/db_schema.sql'
        su -l www-data -c '/usr/bin/createuser repo'
        su -l www-data -c '/usr/bin/createuser guest'
        su -l www-data -c '/usr/bin/createuser gui'
        su -l www-data -c 'echo "CREATE SCHEMA gui AUTHORIZATION gui" | /usr/bin/psql'
    else
        su -l www-data -c '/usr/lib/postgresql/12/bin/pg_ctl start -D /home/www-data/postgresql -l /home/www-data/log/postgresql.log'
    fi
fi

# assure not-superuser user rights
su -l www-data -c "echo \"GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO guest; GRANT USAGE ON SCHEMA public TO guest\" | /usr/bin/psql $PG_CONN"
su -l www-data -c "echo \"GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO gui; GRANT USAGE ON SCHEMA public TO gui; ALTER SCHEMA gui OWNER TO gui;\" | /usr/bin/psql $PG_CONN"
su -l www-data -c "echo \"GRANT SELECT, INSERT, DELETE, UPDATE, TRUNCATE ON ALL TABLES IN SCHEMA public TO repo; GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO repo; GRANT USAGE ON SCHEMA public TO repo\" | /usr/bin/psql $PG_CONN"

# set random passwords for guest and repo users and store them in /home/www-data/.pgpass
for user in repo guest gui; do
    PSWD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32}`
    su -l www-data -c "echo \"ALTER USER $user WITH password '$PSWD'\" | /usr/bin/psql $PG_CONN"
    echo "*:*:*:$user:$PSWD" >> /home/www-data/.pgpass
done
PSWD=""

if [ -e "$PG_CONN" ]; then
    su -l www-data -c '/usr/lib/postgresql/12/bin/pg_ctl stop -D /home/www-data/postgresql'
fi

