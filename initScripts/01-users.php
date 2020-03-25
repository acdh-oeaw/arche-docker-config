#!/usr/bin/php
<?php
/*
 * Creates / manages user accounts according to the __DIR__/users.yaml file
 */

use zozlak\auth\usersDb\PdoDb;
use zozlak\auth\authMethod\HttpBasic;
use zozlak\yaml\Yaml;

require_once '/home/www-data/vendor/autoload.php';

$cfgFile   = '/home/www-data/docroot/api/config.yaml';
$usersFile = __DIR__ . '/users.yaml';

$cfg   = json_decode(json_encode(yaml_parse_file($cfgFile)));
$dbCfg = $cfg->accessControl;
$db    = new PdoDb($dbCfg->db->connStr, $dbCfg->db->table, $dbCfg->db->userCol, $dbCfg->db->dataCol);

// users defined in the users file
if (file_exists($usersFile)) {
    $users = json_decode(json_encode(yaml_parse_file($usersFile)));
    foreach ($users as $u) {
        if (!empty($u->password)) {
            $db->putUser($u->login, HttpBasic::pswdData($u->password));
            $u->password = '';
        }
        $groups = array_merge(['public'], $u->groups ?? []);
        $db->putUser($u->login, (object) ['groups' => $groups]);
    }
    yaml_emit_file($usersFile, json_decode(json_encode($u), true));
}

// ingestion user for init scripts performing ingestions
$pswd = bin2hex(random_bytes(16));
$cfg = new Yaml(__DIR__ . '/config.yaml');
$cfg->set('$.auth.httpBasic', ['user' => 'init', 'password' => $pswd]);
$cfg->writeFile(__DIR__ . '/config.yaml');
$db->putUser('init', HttpBasic::pswdData($pswd));
$db->putUser('init', (object) ['groups' => ['admin']]);

