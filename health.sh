#!/bin/bash
# Health check script for the cluster
# Used also to cleanup drupal's cache

HM=`date +%H:%M`
if [ "$HM" == "05:15" ] ; then
    echo "--- Cleaning up drupal cache"
    /home/www-data/gui/web/modules/contrib/arche-gui/inst/delete_tmp_files.sh
fi

echo "--- Checking describe endpoint"
curl -L -s -f http://127.0.0.1/api/describe > /dev/null || exit 1
echo "--- Checking GUI landing page"
curl -L -s -f "$1/browser" > /dev/null || exit 2
echo "--- Everything OK"
