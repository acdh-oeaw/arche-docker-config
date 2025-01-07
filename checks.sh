#!/bin/bash
# Repository checks to be run periodically (e.g. weekly)
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
LDIR=/home/www-data/log
ODIR=/home/www-data/docroot/status
CDIR=`dirname "$BASH_SOURCE[0]"`

. "$CDIR/cluster_init.sh"

$SDIR/checkHashes.php "$CFGFILE" 2>&1 | tee $LDIR/checkHashes.log
cp $LDIR/checkHashes.log $ODIR/checkHashes.txt
$SDIR/cleanupStorage.php "$CFGFILE" 2>&1 | tee $LDIR/cleanupStorage.log
cp $LDIR/cleanupStorage.log $ODIR/cleanupStorage.txt
$CDIR/checkLinks.php --dbConn "$DBCONN" --retry400WithGet --parallel 5 --timeout 15 --auth "$1" --authNmsp "$2" 2>&1 | tee $LDIR/checkLinks.log
cp $LDIR/checkLinks.log $ODIR/checkLinks.txt
chown www-data:www-data $ODIR/*
