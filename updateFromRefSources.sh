#!/bin/bash
SDIR=/home/www-data/vendor/bin
LDIR=/home/www-data/log
ODIR=/home/www-data/docroot/status
CDIR=`dirname "$BASH_SOURCE[0]"`
VERBOSE="--verbose"
REPOURL="https://arche.acdh.oeaw.ac.at/api/"
ACDH="https://vocabs.acdh.oeaw.ac.at/schema#"

PSWD=`grep "password:" "$CDIR/initScripts/config.yaml" | head -n 1 | sed -E 's/^.*password: *"?(.*)"? *$/\1/g'`
CDIR="$CDIR/ref-sources/"
mkdir -p $ODIR

# acdh:Place
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-place-title.ttl" --class ${ACDH}Place --withoutProperty ${ACDH}hasTitle     $CDIR/place-title.yaml  2>&1 > "$ODIR/ref-place-title_log.txt"
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-place-lat.ttl"   --class ${ACDH}Place --withoutProperty ${ACDH}hasLatitude  $CDIR/place-latlon.yaml 2>&1 > "$ODIR/ref-place-lat_log.txt"
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-place-lon.ttl"   --class ${ACDH}Place --withoutProperty ${ACDH}hasLongitude $CDIR/place-latlon.yaml 2>&1 > "$ODIR/ref-place-lon_log.txt"
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-place-wkt.ttl"   --class ${ACDH}Place --withoutProperty ${ACDH}hasWKT       $CDIR/place-wkt.yaml    2>&1 > "$ODIR/ref-place-wkt_log.txt"

# acdh:Person
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-person-title.ttl"     --class ${ACDH}Person --withoutProperty ${ACDH}hasTitle     $CDIR/person.yaml 2>&1 > "$ODIR/ref-person-title_log.txt"
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-person-firstname.ttl" --class ${ACDH}Person --withoutProperty ${ACDH}hasFirstName $CDIR/person.yaml 2>&1 > "$ODIR/ref-person-firstname.txt"
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-person-lastname.ttl"  --class ${ACDH}Person --withoutProperty ${ACDH}hasLastName  $CDIR/person.yaml 2>&1 > "$ODIR/ref-person-lastname.txt"

# acdh:Organisation
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-organisation.ttl" --class ${ACDH}Organisation --withoutProperty ${ACDH}hasTitle  $CDIR/organisation.yaml 2>&1 > "$ODIR/ref-organisation.txt"

# lacking class and title
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-onlyid-place.ttl"        --withoutProperty ${ACDH}hasTitle  $CDIR/place-title.yaml  2>&1 > "$ODIR/ref-onlyid-place.txt"
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-onlyid-person.ttl"       --withoutProperty ${ACDH}hasTitle  $CDIR/person.yaml       2>&1 > "$ODIR/ref-onlyid-person.txt"
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-onlyid-organisation.ttl" --withoutProperty ${ACDH}hasTitle  $CDIR/organisation.yaml 2>&1 > "$ODIR/ref-onlyid-organisation.txt"

chown www-data:www-data $ODIR/*

