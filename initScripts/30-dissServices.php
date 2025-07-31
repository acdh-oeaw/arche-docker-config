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
    $now = (new DateTimeImmutable())->format(DateTimeImmutable::ISO8601);

    // import current diss services definitions
    $graph->import($cfg->schema->namespaces->id, MetadataCollection::SKIP);

    // find and remove all dissemination service-related resources which were not update
    $query = "
        SELECT id
        FROM metadata m1 JOIN metadata m2 USING (id)
        WHERE 
            m1.property = ? AND substring(m1.value, 1, 100) IN (?, ?, ?)
            AND m2.property = ? AND m2.value_t < ?
    ";
    $param = [
        RDF::RDF_TYPE,
        $cfg->schema->dissService->class,
        $cfg->schema->dissService->matchClass,
        $cfg->schema->dissService->parameterClass,
        $cfg->schema->modificationDate,
        $now,
    ];
    $toRemove = $repo->getResourcesBySqlQuery($query, $param, new SearchConfig());
    foreach ($toRemove as $i) {
        echo "Removing obsolete diss service object " . $i->getUri() . "\n";
        try {
            $i->delete(true, true);
        } catch (Deleted $e) {}
    }

    $repo->commit();
} catch (Exception $e) {
    echo acdhOeaw\arche\lib\exception\ExceptionUtil::unwrap($e) . "\n";
    $repo->rollback();
}

