#!/usr/bin/php
<?php
/*
 * Updates external vocabularies mentioned in the ontology
 */

require_once '/home/www-data/vendor/autoload.php';

$cfgFile                  = __DIR__ . '/config.yaml';
$cfg                     = yaml_parse_file($cfgFile);
$cfg['composerLocation'] = '/home/www-data/vendor/autoload.php';
yaml_emit_file($cfgFile, $cfg);

echo "Importing external vocabularies\n";
system("php -f /home/www-data/vendor/acdh-oeaw/arche-schema-ingest/importVocabularies.php $cfgFile");

