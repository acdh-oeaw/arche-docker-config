#!/usr/bin/php
<?php
/*
 * A script for migrating the production instance metadata to the curation instance.
 * - migrates all the metadata but the history of changes,
 * - preserves users database on the curation instance
 * - migrates title images
 * - takes care of the identifiers migration
 */

include '/home/www-data/vendor/autoload.php';

if (!in_array($argv[1] ?? '', ['dump', 'restore'])) {
    echo "\n$argv[0] [dump|restore]\n\n";
    exit(1);
}

$cfg        = json_decode(json_encode(yaml_parse_file('/home/www-data/config/yaml/config-repo.yaml')));
$pdo        = new PDO($cfg->dbConn->admin);
$schemaDump = 'dump_schema.sql';
$dataDump   = 'dump_data.sql';
$imgsDump   = 'dump_titleimgages.tar';
$usersDump  = 'dump_users.sql';
$cfgDump    = 'dump_config.yaml';

$dbConnParam = array_map(fn($x) => explode('=', $x), explode(' ', $cfg->dbConnStr->admin));
$dbConnParam = array_combine(array_map(fn($x) => $x[0], $dbConnParam), array_map(fn($x) => $x[1] ?? '', $dbConnParam));
$dbConn = '' .
    (isset($dbConnParam['host']) ? " -h '" . $dbConnParam['host'] . "'" : '') .
    (isset($dbConnParam['port']) ? " -p '" . $dbConnParam['port'] . "'" : '') .
    (isset($dbConnParam['user']) ? " -U '" . $dbConnParam['user'] . "'" : '') .
    (isset($dbConnParam['dbname']) ? " '" . $dbConnParam['dbname'] . "'" : '') ;

if ($argv[1] === 'dump') {
    $basePath = $cfg->storage->dir;
    $levelMax = $cfg->storage->levels;

    function getStorageDir(int $id, string $path, int $level, int $levelMax): string {
	$idTmp = $id;
        while ($level < $levelMax) {
            $path .= sprintf('/%02d', $idTmp % 100);
            $idTmp = (int) $idTmp / 100;
            $level++;
        }
        return $path . '/' . $id;
    }

    echo "Copying repository config\n";
    copy('/home/www-data/config/yaml/config-repo.yaml', "$basePath/$cfgDump");
    echo "Dumping schema\n";
    #system('pg_dump -f ' . escapeshellarg("$basePath/$schemaDump") . ' -C -s ' . $dbConn);
    echo "Dumping metadata\n";
    #system('pg_dump -f ' . escapeshellarg("$basePath/$dataDump") . ' -a -T metadata_history -T users ' . $dbConn);

    echo "Dumping title images\n";
    $query = $pdo->prepare("SELECT id FROM relations r JOIN metadata m USING (id) WHERE r.property = ? AND m.property = ? ORDER BY 1");
    $query->execute([$cfg->schema->titleImage, $cfg->schema->hash]);
    $imgs = '';
    while($id = $query->fetchColumn()) {
        $imgs .= " " . escapeshellarg(getStorageDir($id, '.', 0, $levelMax));
    }
    chdir($basePath);
    system('tar -c -f ' . escapeshellarg("$basePath/$imgsDump") . $imgs);
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

