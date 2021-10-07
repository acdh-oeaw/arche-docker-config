#!/bin/bash
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
LDIR=/home/www-data/log
ODIR=/home/www-data/docroot/status

mkdir -p $ODIR
$SDIR/checkHashes.php /home/www-data/docroot/api/config.yaml | tee $ODIR/checkHashes.log > $LDIR/checkHashes.log 2>&1
$SDIR/cleanupStorage.php /home/www-data/docroot/api/config.yaml | tee $ODIR/cleanupStorage.log >> $LDIR/cleanupStorage.log 2>&1

