#!/bin/bash
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
LDIR=/home/www-data/log
ODIR=/home/www-data/docroot/status
CDIR=`dirname "$BASH_SOURCE[0]"`

mkdir -p $ODIR
$SDIR/checkHashes.php /home/www-data/docroot/api/config.yaml | tee $ODIR/checkHashes.log > $LDIR/checkHashes.log 2>&1
$SDIR/cleanupStorage.php /home/www-data/docroot/api/config.yaml | tee $ODIR/cleanupStorage.log >> $LDIR/cleanupStorage.log 2>&1
$CDIR/checkLinks.php --retry400WithGet --parallel 5 --timeout 15 | tee $ODIR/checkLinks.log > $LDIR/checkLinks.log 2>&1

