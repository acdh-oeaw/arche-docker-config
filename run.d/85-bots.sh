#!/bin/bash
curl https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/refs/heads/main/robots.txt > /home/www-data/docroot/robots.txt &&\
  cp /home/www-data/docroot/robots.txt /home/www-data/docroot/resolver/robots.txt
curl https://github.com/ai-robots-txt/ai.robots.txt/blob/main/.htaccess > /etc/apache2/conf-available/bots.conf
