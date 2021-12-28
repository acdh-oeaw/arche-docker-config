#!/usr/bin/php
<?php
/*
 * A script for migrating the production instance metadata to the curation instance.
 * - migrates all the metadata but the history of changes,
 * - preserves users database on the curation instance
 * - migrates title images
 * - takes care of the identifiers migration
 */

include $_SERVER['HOME'] . '/vendor/autoload.php';

if (!in_array($argv[1] ?? '', ['dump', 'restore'])) {
    echo "\n$argv[0] [dump|restore]\n\n";
    exit(1);
}

$cfg        = json_decode(json_encode(yaml_parse_file($_SERVER['HOME'] . '/config/yaml/config-repo.yaml')));
$pdo        = new PDO($cfg->dbConn->guest);
$schemaDump = 'dump_schema.sql';
$dataDump   = 'dump_data.sql';
$imgsDump   = 'dump_titleimgages.tar';
$usersDump  = 'dump_users.sql';
$cfgDump    = 'dump_config.yaml';

if ($argv[1] === 'dump') {
    $basePath = $cfg->storage->dir;
    $levelMax = $cfg->storage->levels;

    function getStorageDir(int $id, string $path, int $level, int $levelMax): string {
        if ($level < $levelMax) {
            $path = sprintf('%s/%02d', $path, $id % 100);
            $path = getStorageDir((int) $id / 100, $path, $level + 1, $levelMax);
        }
        return $path;
    }

    echo "Copying repository config\n";
    copy($_SERVER['HOME'] . '/config/yaml/config-repo.yaml', "$basePath/$cfgDump");
    echo "Dumping schema\n";
    system('pg_dump -f ' . escapeshellarg("$basePath/$schemaDump") . ' -C -s');
    echo "Dumping metadata\n";
    system('pg_dump -f ' . escapeshellarg("$basePath/$dataDump") . ' -a -T metadata_history -T users');

    echo "Dumping title images\n";
    $query = $pdo->prepare("SELECT id FROM relations WHERE property = ? ORDER BY 1");
    $query->execute([$cfg->schema->titleImage]);
    $imgs = '';
    while($id = $query->fetchColumn()) {
        $imgs .= " " . escapeshellarg(getStorageDir($id, '', 0, $levelMax));
    }
    chdir($basePath);
    escapeshellarg('tar -c -f ' . escapeshellarg("$basePath/$imgsDump") . $imgs);
    echo "\nDump completed - copy all the $basePath/dump_* files to the curation instance and run the script with the 'restore' parameter there.\n\n";
} else {
    foreach ([$schemaDump, $dataDump, $imgsDump, $cfgDump] as $i) {
        if (!file_exists($i)) {
            echo "Missing dump file $i (should be in the current working directory)\n";
            exit(2);
        }
    }     
    $user = posix_getpwuid(posix_geteuid())['name'];
    if ($user === 'root') {
        echo "Can't be run as root.\n";
        exit(3);
    }

    echo "Creating users database backup\n";
    system("pg_dump -a -t users -f $usersDump");
    echo "Recreating the database\n";
    system("dropdb " . escapeshellarg($user));
    system("createdb " . escapeshellarg($user));
    echo "Migrating schema\n";
    system("psql -f " . escapeshellarg($schemaDump));
    echo "Migrating data\n";
    system("psql -f " . escapeshellarg($dataDump));
    echo "Restoring users database\n";
    system("psql -f " . escapeshellarg($usersDump));
    echo "Updating base indentifiers\n";
    $oldCfg    = json_decode(json_encode(yaml_parse_file($cfgDump)));
    $oldIdBase = $oldCfg->rest->urlBase . $oldCfg->rest->pathBase;
    $newIdBase = $cfg->rest->urlBase . $cfg->rest->pathBase;
    $query     = $pdo->prepare("INSERT INTO identifiers (ids, id) SELECT replace(ids, ?, ?), id FROM identifiers WHERE ids LIKE ?");
    $query->execute([$oldIdBase, $newIdBase, "$oldIdBase%"]);
    echo "\nMigration finished\n\n";
}

