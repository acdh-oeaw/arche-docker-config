#!/bin/bash
LD=/home/www-data/log

# compress big logs
MAX_SIZE=1048576000 # 100M
DATE=`date +"%Y-%m-%d"`
for i in `ls -1 $LD | grep -v gz$`; do
    if (( `du -b $LD/$i | cut -f -1` > $MAX_SIZE )) ; then
        echo "Compressing log file $i"
	mv "$LD/$i" "$LD/${i}_$DATE" && gzip -9 "$LD/${i}_$DATE"
    fi
done
