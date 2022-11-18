#!/usr/bin/php
<?php
/*
 * Assures most recent ontology version is ingested.
 *
 * All runtime parameters are passed to the arche-import-ontology script
 */

require_once '/home/www-data/vendor/autoload.php';

$cfg = yaml_parse_file(__DIR__ . '/config.yaml')['auth']['httpBasic'];
$user = escapeshellarg($cfg['user']);
$pswd = escapeshellarg($cfg['password']);
$args = implode(' ', array_map('escapeshellarg', array_slice($argv, 1)));

setDoorkeeperChecks(false);
echo "Importing ontology\n";
system("/home/www-data/vendor/bin/arche-import-ontology --user $user --pswd $pswd --concurrency 6 $args http://127.0.0.1/api");
setDoorkeeperChecks(true);

// helper functions

function setDoorkeeperChecks(bool $restoreOrFalse): void {
    $sCfgFile = __DIR__ . '/../yaml/config-repo.yaml';
    static $dCfgBak = [];
    $sCfg           = yaml_parse_file($sCfgFile);
    $dCfgBakTmp     = $sCfg['doorkeeper'];
    $sCfg['doorkeeper']['checkUnknownProperties']    = $restoreOrFalse ? $dCfgBak['checkUnknownProperties'] : false;
    $sCfg['doorkeeper']['checkAutoCreatedResources'] = $restoreOrFalse ? $dCfgBak['checkAutoCreatedResources'] : false;
    $sCfg['doorkeeper']['checkVocabularyValues']     = $restoreOrFalse ? $dCfgBak['checkVocabularyValues'] : false;
    yaml_emit_file($sCfgFile, $sCfg);
    $dCfgBak  = $dCfgBakTmp;
}
