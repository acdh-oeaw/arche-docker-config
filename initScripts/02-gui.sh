#!/bin/bash
echo "Running psql -h 127.0.0.1 -h $PG_HOST -p $PG_PORT -U ${PG_USER_PREFIX}gui -f /home/www-data/gui/web/modules/contrib/arche-gui/inst/dbfunctions.sql $PG_DBNAME"
psql -h 127.0.0.1 -h $PG_HOST -p $PG_PORT -U ${PG_USER_PREFIX}gui -f /home/www-data/gui/web/modules/contrib/arche-gui/inst/dbfunctions.sql $PG_DBNAME

