#!/usr/bin/php
<?php
/*
 * Checks if the ontology is present in the repo and up to date.
 * If not, imports it.
 */

require_once '/home/www-data/vendor/autoload.php';
use acdhOeaw\arche\lib\Repo;
use acdhOeaw\arche\lib\exception\NotFound;

$cfgFile      = __DIR__ . '/config.yaml';
$ontologyFile = '/home/www-data/vendor/acdh-oeaw/arche-schema/acdh-schema.owl';

$cfg                     = yaml_parse_file($cfgFile);
$cfg['composerLocation'] = '/home/www-data/vendor/autoload.php';
yaml_emit_file($cfgFile, $cfg);

$repo    = Repo::factory($cfgFile);
$import  = true;
try {
    $res    = $repo->getResourceById(preg_replace('/#$/', '', $cfg['schema']['namespaces']['ontology']));
    $hash   = (string) $res->getGraph()->getLiteral($cfg['schema']['hash']);
    $md5    = 'md5:' . md5_file($ontologyFile);
    $sha1   = 'sha1:' . sha1_file($ontologyFile);
    $import = !in_array($hash, [$md5, $sha1]);
} catch (NotFound $e) {

}

if ($import || ($argv[1] ?? false)) {
    // turn off some doorkeeper checks
    $sCfgFile = __DIR__ . '/../yaml/config-repo.yaml';
    $sCfg     = yaml_parse_file($sCfgFile);
    $dCfgBak  = $sCfg['doorkeeper'];
    $sCfg['doorkeeper']['checkUnknownProperties']    = false;
    $sCfg['doorkeeper']['checkAutoCreatedResources'] = false;
    yaml_emit_file($sCfgFile, $sCfg);

    echo "Importing ontology\n";
    system("php -f /home/www-data/vendor/acdh-oeaw/arche-schema-ingest/importOntology.php $cfgFile $ontologyFile --skipVocabularies");
    
    // restore doorkeeper checks
    $sCfg['doorkeeper']['checkUnknownProperties']    = $dCfgBak['checkUnknownProperties'];
    $sCfg['doorkeeper']['checkAutoCreatedResources'] = $dCfgBak['checkAutoCreatedResources'];
    yaml_emit_file($sCfgFile, $sCfg);
} else {
    echo "Ontology up to date\n";
}

