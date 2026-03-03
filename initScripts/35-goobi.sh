#!/bin/bash
composer require acdh-oeaw/arche-ingest &&\
  curl https://arche.acdh.oeaw.ac.at/api/997283 > /tmp/mahler.png &&\
  echo '<https://id.acdh.oeaw.ac.at/mahler.png> <https://vocabs.acdh.oeaw.ac.at/schema#aclRead> "public".' > /tmp/mahler.ttl &&\
  vendor/bin/arche-import-binary --maxDepth 0 --filenameFilter mahler.png /tmp https://id.acdh.oeaw.ac.at http://127.0.0.1/api/ admin "$ADMIN_PSWD" &&\
  vendor/bin/arche-import-metadata /tmp/mahler.ttl http://127.0.0.1/api/ admin "$ADMIN_PSWD" &&\
  rm /tmp/mahler*
