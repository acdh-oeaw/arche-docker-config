#!/bin/bash
echo "Running psql -f /home/www-data/gui/web/modules/contrib/arche_core_gui/inst/dbfunctions.sql $PG_CONN"
psql -f /home/www-data/gui/web/modules/contrib/arche_core_gui/inst/dbfunctions.sql $PG_CONN

