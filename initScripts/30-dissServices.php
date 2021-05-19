#!/usr/bin/php
<?php
/*
 * Checks if the ontology is present in the repo and up to date.
 * If not, imports it.
 */

require_once '/home/www-data/vendor/autoload.php';
use acdhOeaw\arche\lib\Repo;
use acdhOeaw\arche\lib\RepoResourceInterface;
use acdhOeaw\arche\lib\SearchTerm;
use acdhOeaw\arche\lib\SearchConfig;
use acdhOeaw\arche\lib\exception\Deleted;
use acdhOeaw\arche\lib\ingest\MetadataCollection;
use zozlak\RdfConstants as RDF;


MetadataCollection::$debug = true;
$cfgFile   = __DIR__ . '/config.yaml';
$cfg       = json_decode(json_encode(yaml_parse_file($cfgFile)));
$repo      = Repo::factory($cfgFile);
$graph     = new MetadataCollection($repo, __DIR__ . '/dissServices.ttl');
$repo->begin();
try {
    // get all existing diss services and their children (match rules and parameters)
    $query = "
        SELECT (get_relatives(id, ?, 1, 0)).id
        FROM metadata
        WHERE property = ? AND substring(value, 1, 100) = ?
    ";
    $param = [$cfg->schema->parent, RDF::RDF_TYPE, $cfg->schema->dissService->class];
    $sc = new SearchConfig();
    $sc->metadataMode = RepoResourceInterface::META_RESOURCE;
    $existing = $repo->getResourcesBySqlQuery($query, $param, $sc);

    // import current diss services definitions
    $resources = $graph->import($cfg->schema->namespaces->id, MetadataCollection::SKIP);

    // remove obsolete dissemination services and/or their parameters/match rules
    $valid = [];
    foreach ($resources as $i) {
        $valid[] = $i->getUri();
    }
    foreach ($existing as $i) {
        if (!in_array($i->getUri(), $valid)) {
            echo "Removing obsolete diss service " . $i->getUri() . "\n";
            try {
                $i->deleteRecursively($cfg->schema->parent, true, true);
            } catch (Deleted $e) {}
        }
    }

    $repo->commit();
} catch (Exception $e) {
    //print_r($e);
    echo $e->getMessage()."\n";
    $repo->rollback();
}

