#!/bin/bash
SDIR=/home/www-data/vendor/acdh-oeaw/arche-core
LDIR=/home/www-data/log

$SDIR/checkHashes.php /home/www-data/docroot/api/config.yaml > $LDIR/checkHashes.log 2>&1
$SDIR/cleanupStorage.php /home/www-data/docroot/api/config.yaml >> $LDIR/cleanupStorage.log 2>&1

