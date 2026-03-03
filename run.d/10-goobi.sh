#!/bin/bash
touch /etc/authbind/byport/443 &&\
  chmod 755 /etc/authbind/byport/* &&\
  a2enmod ssl &&\
  a2enmod proxy_http &&\
  usermod -a -G ssl-cert www-data &&\
  cp /home/www-data/config/yaml/local-goobi.yaml /home/www-data/config/yaml/local.yaml
