#!/bin/bash
psql -h 127.0.0.1 $PG_CONN -U ${PG_USER_PREFIX}gui -f /home/www-data/gui/web/modules/contrib/arche-gui/inst/dbfunctions.sql $PG_DBNAME

