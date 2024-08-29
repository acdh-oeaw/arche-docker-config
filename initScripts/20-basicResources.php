#!/usr/bin/php
<?php
/*
 * Checks if the ontology is present in the repo and up to date.
 * If not, imports it.
 */

require_once '/home/www-data/vendor/autoload.php';
use acdhOeaw\arche\lib\Repo;
use acdhOeaw\arche\lib\BinaryPayload;
use acdhOeaw\arche\lib\ingest\MetadataCollection;

MetadataCollection::$debug = true;
$cfgFile   = __DIR__ . '/config.yaml';
$cfg       = json_decode(json_encode(yaml_parse_file($cfgFile)));
$repo      = Repo::factory($cfgFile);
$graph     = new MetadataCollection($repo, __DIR__ . '/basicResources.ttl');

try {
    echo "Importing basicResources.ttl\n";
    $repo->begin();
    $resources = $graph->import($cfg->schema->namespaces->id, MetadataCollection::SKIP);
    $repo->commit();
    echo "\tsuccessful\n";

    echo "Importing restrictedAccessImage.png\n";
    $repo->begin();
    $res = $repo->getResourceById('https://id.acdh.oeaw.ac.at/restrictedAccessImage');
    $res->updateContent(new BinaryPayload(null, __DIR__ . '/restrictedAccessImage.png', 'image/png'));
    $repo->commit();
    echo "\tsuccessful\n";
} catch (Exception $e) {
    echo acdhOeaw\arche\lib\exception\ExceptionUtil::unwrap($e) . "\n";
    $repo->rollback();
}
