#!/bin/bash
# Repository checks to be run periodically (e.g. weekly)
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
LDIR=/home/www-data/log
ODIR=/home/www-data/docroot/status
CDIR=`dirname "$BASH_SOURCE[0]"`

. "$CDIR/cluster_init.sh"

$SDIR/checkHashes.php "$CFGFILE" 2>&1 | tee $ODIR/checkHashes.txt $LDIR/checkHashes.log
$SDIR/cleanupStorage.php "$CFGFILE" 2>&1 | tee $ODIR/cleanupStorage.txt $LDIR/cleanupStorage.log
$CDIR/checkLinks.php --dbConn "$DBCONN" --retry400WithGet --parallel 5 --timeout 15 --auth "$1" --authNmsp "$2" 2>&1 | tee $ODIR/checkLinks.txt $LDIR/checkLinks.log

