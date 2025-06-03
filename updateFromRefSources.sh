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
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-place-title.ttl" --class ${ACDH}Place --withoutProperty ${ACDH}hasTitle     $CDIR/place-title.yaml  > "$ODIR/ref-place-title_log.txt" 2>&1
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-place-lat.ttl"   --class ${ACDH}Place --withoutProperty ${ACDH}hasLatitude  $CDIR/place-latlon.yaml > "$ODIR/ref-place-lat_log.txt"   2>&1
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-place-lon.ttl"   --class ${ACDH}Place --withoutProperty ${ACDH}hasLongitude $CDIR/place-latlon.yaml > "$ODIR/ref-place-lon_log.txt"   2>&1
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-place-wkt.ttl"   --class ${ACDH}Place --withoutProperty ${ACDH}hasWKT       $CDIR/place-wkt.yaml    > "$ODIR/ref-place-wkt_log.txt"   2>&1

# acdh:Person
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-person-title.ttl"     --class ${ACDH}Person --withoutProperty ${ACDH}hasTitle     $CDIR/person.yaml > "$ODIR/ref-person-title_log.txt" 2>&1
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-person-firstname.ttl" --class ${ACDH}Person --withoutProperty ${ACDH}hasFirstName $CDIR/person.yaml > "$ODIR/ref-person-firstname.txt" 2>&1
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-person-lastname.ttl"  --class ${ACDH}Person --withoutProperty ${ACDH}hasLastName  $CDIR/person.yaml > "$ODIR/ref-person-lastname.txt"  2>&1

# acdh:Organisation
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-organisation.ttl" --class ${ACDH}Organisation --withoutProperty ${ACDH}hasTitle  $CDIR/organisation.yaml > "$ODIR/ref-organisation.txt" 2>&1

# lacking class and title
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-onlyid-place.ttl"        --withoutProperty ${ACDH}hasTitle  $CDIR/place-title.yaml  > "$ODIR/ref-onlyid-place.txt"        2>&1
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-onlyid-person.ttl"       --withoutProperty ${ACDH}hasTitle  $CDIR/person.yaml       > "$ODIR/ref-onlyid-person.txt"       2>&1
$SDIR/arche-ref-sources --user init --pswd "$PSWD" --repositoryUrl $REPOURL --mode update $VERBOSE --output "$ODIR/ref-onlyid-organisation.ttl" --withoutProperty ${ACDH}hasTitle  $CDIR/organisation.yaml > "$ODIR/ref-onlyid-organisation.txt" 2>&1

# once a month scrap ids
if [ "`date +%d`" == "01" ] ; then
    $SDIR/arche-ref-sources --repositoryUrl $REPOURL --mode resolve cfg/id.yaml --output "$ODIR/ids.ttl" > "$ODIR/ref-ids.txt" 2>&1
fi

chown www-data:www-data $ODIR/*

