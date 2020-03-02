#!/usr/bin/php
<?php
/*
 * Checks if the ontology is present in the repo and up to date.
 * If not, imports it.
 */

require_once '/home/www-data/docroot/vendor/autoload.php';
use acdhOeaw\acdhRepoLib\Repo;
use acdhOeaw\acdhRepoIngest\MetadataCollection;

MetadataCollection::$debug = true;
$cfgFile   = '/home/www-data/docroot/config.yaml';
$cfg       = json_decode(json_encode(yaml_parse_file($cfgFile)));
$repo      = Repo::factory($cfgFile);
$graph     = new MetadataCollection($repo, __DIR__ . '/basicResources.ttl');
$repo->begin();
try {
    $resources = $graph->import($cfg->schema->namespaces->id, MetadataCollection::SKIP);
    $repo->commit();
} catch (Exception $e) {
    //print_r($e);
    echo $e->getMessage()."\n";
    $repo->rollback();
}

