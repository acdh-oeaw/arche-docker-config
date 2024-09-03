#!/bin/bash

PG_VERSION="`ls -1 /usr/lib/postgresql/ | head -n 1`"
DB_CONF_YAML=/home/www-data/config/yaml/config-db.yaml

# cleanup faulty shutdowns
rm -f /home/www-data/postgresql/postmaster.pid /var/run/postgresql/.s.PGSQL.5432.lock

if [ ! -z "$PG_EXTERNAL" ]; then
    if [ "0" == "`su -l www-data -c "/usr/bin/psql -l $PG_CONN | grep $PG_DBNAME | wc -l"`" ]; then
	echo "creating the database"
        su -l www-data -c "echo \"CREATE DATABASE $PG_DBNAME\" | /usr/bin/psql -v ON_ERROR_STOP=on -h $PG_HOST -p $PG_PORT -U $PG_USER postgres" &&\
        INIT_DB=1
	if [ "$?" != "0" ] ; then
	    echo "    database creation failed - you need user with admin rights to do it"
	fi
    fi
else
    if [ ! -f /home/www-data/postgresql/postgresql.conf ]; then
        # initialize local database cluster
	echo "initializing local database cluster"
        su -l www-data -c "/usr/lib/postgresql/$PG_VERSION/bin/initdb -D /home/www-data/postgresql --auth=ident -U www-data --locale en_US.UTF-8" &&\
        sed -i -E 's/^(host.*ident)$/#\1/g' /home/www-data/postgresql/pg_hba.conf &&\
        echo "host    all             all             127.0.0.1/32            md5" >> /home/www-data/postgresql/pg_hba.conf &&\
        su -l www-data -c "/usr/lib/postgresql/$PG_VERSION/bin/pg_ctl start -D /home/www-data/postgresql -l /home/www-data/log/postgresql.log" &&\
        su -l www-data -c "createdb $PG_DBNAME" &&\
        INIT_DB=1 &&\
	echo "    initialization successfull"
    else
        su -l www-data -c "/usr/lib/postgresql/$PG_VERSION/bin/pg_ctl start -D /home/www-data/postgresql -l /home/www-data/log/postgresql.log"
    fi
fi
if [ "1" == "$INIT_DB" ]; then
    if [ -f "/home/www-data/data/dump.sql" ] ; then
        # automatic pickup of a previous database version dump
        echo "restoring previous database dump from /home/www-data/data/dump.sql"
        su -l www-data -c "/usr/bin/psql -f /home/www-data/data/dump.sql $PG_CONN"
    else
	echo "creating database schema"
        su -l www-data -c "/usr/bin/psql -v ON_ERROR_STOP=on -f /home/www-data/vendor/acdh-oeaw/arche-core/build/db_schema.sql $PG_CONN" &&\
        su -l www-data -c "echo \"CREATE USER ${PG_USER_PREFIX}repo; CREATE USER ${PG_USER_PREFIX}guest; CREATE USER ${PG_USER_PREFIX}gui\" | /usr/bin/psql -v ON_ERROR_STOP=on $PG_CONN" &&\
        su -l www-data -c "echo \"CREATE SCHEMA gui AUTHORIZATION ${PG_USER_PREFIX}gui\" | /usr/bin/psql -v ON_ERROR_STOP=on $PG_CONN" &&\
	echo "    schema created successfully"
	if [ "$?" != "0" ] ; then
	    echo "    schema creation failed - you may need user with admin rights to do it"
	fi
    fi
fi

# assure not-superuser user rights
echo "trying to grant rights to unpriviledged users..."
su -l www-data -c "echo \"GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO ${PG_USER_PREFIX}guest; GRANT USAGE ON SCHEMA public TO ${PG_USER_PREFIX}guest\" | /usr/bin/psql -v ON_ERROR_STOP=on $PG_CONN 2>/dev/null" &&\
su -l www-data -c "echo \"GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO ${PG_USER_PREFIX}gui; GRANT USAGE ON SCHEMA public TO ${PG_USER_PREFIX}gui; ALTER SCHEMA gui OWNER TO ${PG_USER_PREFIX}gui;\" | /usr/bin/psql -v ON_ERROR_STOP=on $PG_CONN 2>/dev/null" &&\
su -l www-data -c "echo \"GRANT SELECT, INSERT, DELETE, UPDATE, TRUNCATE ON ALL TABLES IN SCHEMA public TO ${PG_USER_PREFIX}repo; GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO ${PG_USER_PREFIX}repo; GRANT USAGE ON SCHEMA public TO ${PG_USER_PREFIX}repo\" | /usr/bin/psql -v ON_ERROR_STOP=on $PG_CONN 2>/dev/null" &&\
echo "    succeeded"

if [ "$?" != "0" ] ; then
    # PG_USER has no rights to manage user accounts - fall back to a single user account
    echo "    failed - falling back to single user settings"
    echo "setting up database connection config yaml"
    PDO_CONN="pgsql: host=$PG_HOST port=$PG_PORT user=$PG_USER dbname=$PG_DBNAME"
    echo -e "dbConnStr:\n  repo: '$PDO_CONN'\n  guest: '$PDO_CONN'\n  gui: '$PDO_CONN'" > "$DB_CONF_YAML"
else
    # set random passwords for guest and repo users and store them in /home/www-data/.pgpass
    echo "setting unpriviledged users passwords..."
    echo "dbConnStr:" > "$DB_CONF_YAML"
    for user in repo guest gui; do
        PSWD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32}`
        su -l www-data -c "echo \"ALTER USER ${PG_USER_PREFIX}$user WITH password '$PSWD'\" | /usr/bin/psql $PG_CONN"
        echo "$PG_HOST:$PG_PORT:$PG_DBNAME:${PG_USER_PREFIX}$user:$PSWD" >> /home/www-data/.pgpass
	echo "  $user: 'pgsql: host=$PG_HOST port=$PG_PORT user=${PG_USER_PREFIX}$user dbname=$PG_DBNAME'" >> "$DB_CONF_YAML"
        if [ "$user" == "repo" ] ; then
            IP="`cat /etc/hosts | grep -E '^[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+' | grep -v localhost | head -n 1 | sed -e 's/\s.*//'`"
            echo "$IP:5432:www-data:${PG_USER_PREFIX}$user:$PSWD" > /home/www-data/config/backup_pgpass &&\
            chmod 600 /home/www-data/config/backup_pgpass
        fi
    done
    echo "    done"
fi
PSWD=""

if [ -z "$PG_EXTERNAL" ]; then
    su -l www-data -c "/usr/lib/postgresql/$PG_VERSION/bin/pg_ctl stop -D /home/www-data/postgresql"
fi

