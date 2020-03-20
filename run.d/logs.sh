#!/bin/bash
LD=/home/www-data/log

# remove supervisor logs
rm -f $LD/apache2.log $LD/initScripts.log $LD/postgresql.log $LD/supervisor.log $LD/supervisor.pid $LD/txDaemon.log

# compress persistent logs
MAX_SIZE=104857600 # 10M
for i in `ls -1 $LD`; do
    if (( `du -b $LD/$ii | cut -f -1` > $MAX_SIZE )) ; then
        echo "Compressing log file $i" 
        gzip -9 $LD/$i && mv $LD/$i.gz $LD/${i}_`date +"%Y-%m-%d"`.gz
    fi
done
