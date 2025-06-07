#!/usr/bin/php
<?php
/*
 * Creates init user account used to ingest data by other init scripts
 */

use zozlak\auth\usersDb\PdoDb;
use zozlak\auth\authMethod\HttpBasic;
use zozlak\yaml\Yaml;

require_once '/home/www-data/vendor/autoload.php';

$cfgFile   = '/home/www-data/docroot/api/config.yaml';

$cfg   = json_decode(json_encode(yaml_parse_file($cfgFile)));
$dbCfg = $cfg->accessControl;
$db    = new PdoDb($dbCfg->db->connStr, $dbCfg->db->table, $dbCfg->db->userCol, $dbCfg->db->dataCol);

// ingestion user for init scripts performing ingestions
$pswd = bin2hex(random_bytes(16));
$cfg = new Yaml(__DIR__ . '/config.yaml');
$cfg->set('$.auth.httpBasic', ['user' => 'init', 'password' => $pswd]);
$cfg->writeFile(__DIR__ . '/config.yaml');
$db->putUser('init', HttpBasic::pswdData($pswd));
$db->putUser('init', (object) ['groups' => ['admin']]);

