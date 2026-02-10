#!/bin/bash
curl -f https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/refs/heads/main/robots.txt > /tmp/robots.txt &&\
  cp /tmp/robots.txt /home/www-data/docroot/robots.txt &&\
  cp /tmp/robots.txt /home/www-data/docroot/resolver/robots.txta &&\
  rm -f /tmp/robots.txt
curl -f https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/refs/heads/main/.htaccess > /tmp/htaccess &&\
  cp /tmp/htaccess /etc/apache2/conf-available/bots.conf &&\
  rm -f /tmp/htaccess
