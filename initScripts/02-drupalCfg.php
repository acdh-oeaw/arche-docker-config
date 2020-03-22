#!/usr/bin/php
<?php
/*
 * Creates / manages user accounts according to the __DIR__/users.yaml file
 */

use zozlak\auth\usersDb\PdoDb;
use zozlak\auth\authMethod\HttpBasic;
use zozlak\yaml\Yaml;

require_once '/home/www-data/docroot/vendor/autoload.php';

$guestPswd = '';
foreach (explode("\n", file_get_contents('/home/www-data/.pgpass')) as $l) {
    $l = explode(':', trim($l));
    if (($l[3] ?? '') === 'guest') {
        $guestPswd = $l[4];
        break;
    }
}

if (!file_exists('/home/www-data/gui')) {
    mkdir('/home/www-data/gui', 0700);
}

$yaml = new Yaml('/home/www-data/config/yaml/schema.yaml');
$yaml->merge('/home/www-data/config/yaml/drupal.yaml');
$yaml->merge('/home/www-data/config/yaml/local.yaml');
$dbConnStr = $yaml->get('$.dbConnStr.guest');
$yaml->set('$.dbConnStr.guest', $dbConnStr . " password=$guestPswd");
$yaml->writeFile('/home/www-data/gui/config.yaml');

