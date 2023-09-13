#!/bin/bash
SDIR=/home/www-data/vendor/bin
LDIR=/home/www-data/log
ODIR=/home/www-data/docroot/status
CDIR=`dirname "$BASH_SOURCE[0]"`

PSWD=`grep "password:" "$CDIR/initScripts/config.yaml" | head -n 1 | sed -E 's/^.*password: *"?(.*)"? *$/\1/g'`
mkdir -p $ODIR
$SDIR/arche-ref-sources --output "$ODIR/refsources.ttl" --user init --pswd "$PSWD" --mode update --verbose --afterFile "$CDIR/yaml/refsources.lastDate" "$CDIR/yaml/config-refsources.yaml" 2>&1 > "$ODIR/refsources.log"

