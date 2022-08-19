#!/usr/bin/php
<?php
/*
 * Updates external vocabularies used by the ontology
 *
 * All runtime parameters are passed to the arche-import-vocabularies script
 */

require_once '/home/www-data/vendor/autoload.php';

$cfg = yaml_parse_file(__DIR__ . '/config.yaml')['auth']['httpBasic'];
$user = escapeshellarg($cfg['user']);
$pswd = escapeshellarg($cfg['password']);
$args = implode(' ', array_map('escapeshellarg', array_slice($argv, 1)));

echo "Importing external vocabularies\n";
# all arche: properties are skipped because the quite often don't follow the current ontology
system("/home/www-data/vendor/bin/arche-import-vocabularies http://127.0.0.1/api --user $user --pswd $pswd --concurrency 6 --makePublic --dropHasTopConcept --allowedNmsp 'http://www.w3.org/2004/02/skos/core#' 'http://purl.org/dc/' $args");


