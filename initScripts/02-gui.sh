#!/bin/bash
echo "Running psql -h $PG_HOST -p $PG_PORT -U ${PG_USER_PREFIX}gui -f /home/www-data/gui/web/modules/contrib/arche_core_gui/inst/dbfunctions.sql $PG_DBNAME"
psql -h $PG_HOST -p $PG_PORT -U ${PG_USER_PREFIX}gui -f /home/www-data/gui/web/modules/contrib/arche_core_gui/inst/dbfunctions.sql $PG_DBNAME

