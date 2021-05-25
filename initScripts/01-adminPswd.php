#!/usr/bin/php
<?php
/*
 * Sets up admin user password
 */

use zozlak\auth\usersDb\PdoDb;
use zozlak\auth\authMethod\HttpBasic;

require_once '/home/www-data/vendor/autoload.php';

$cfgFile   = '/home/www-data/docroot/api/config.yaml';
$adminPswd = getenv('ADMIN_PSWD');

if (!empty($adminPswd)) {
    $cfg   = json_decode(json_encode(yaml_parse_file($cfgFile)));
    $dbCfg = $cfg->accessControl;
    $db    = new PdoDb($dbCfg->db->connStr, $dbCfg->db->table, $dbCfg->db->userCol, $dbCfg->db->dataCol);
    $db->putUser('admin', (object) HttpBasic::pswdData($adminPswd));
}
