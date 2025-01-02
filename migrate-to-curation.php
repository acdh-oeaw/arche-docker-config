#!/usr/bin/php
<?php
/*
 * A script for migrating the production instance metadata to the curation instance.
 * - migrates all the metadata (including spatial and fts indices) but the history of metadata changes,
 * - does not affect users database on the curation instance
 * - migrates title images
 * - takes care of the identifiers migration
 *
 * When running the restore, specify a dbUser being an owner of the migrated database tables.
 * This is required to disable triggers during the import
 * (and disabling triggers is required for the migration to work).
 */

include '/home/www-data/vendor/autoload.php';

if (!in_array($argv[1] ?? '', ['dump', 'restore'])) {
    echo "\n$argv[0] dump\n  or\n$argv[0] restore [dbUser]\n\n";
    exit(1);
}

$cfg        = json_decode(json_encode(yaml_parse_file('/home/www-data/config/yaml/config-repo.yaml')));
$pdo        = new PDO($cfg->dbConn->admin);
$dataDump   = 'dump_data.sql';
$imgsDump   = 'dump_titleimgages.tar';
$usersDump  = '/tmp/dump_users.sql';
$cfgDump    = 'dump_config.yaml';

$dbConnParam = array_map(fn($x) => explode('=', $x), explode(' ', $cfg->dbConnStr->admin));
$dbConnParam = array_combine(array_map(fn($x) => $x[0], $dbConnParam), array_map(fn($x) => $x[1] ?? '', $dbConnParam));

if ($argv[1] === 'dump') {
    $dbConn = '' .
        (isset($dbConnParam['host']) ? " -h '" . $dbConnParam['host'] . "'" : '') .
        (isset($dbConnParam['port']) ? " -p '" . $dbConnParam['port'] . "'" : '') .
        (isset($dbConnParam['user']) ? " -U '" . $dbConnParam['user'] . "'" : '') .
        (isset($dbConnParam['dbname']) ? " '" . $dbConnParam['dbname'] . "'" : '') ;
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
    echo "Dumping metadata\n";
    system('pg_dump -f ' . escapeshellarg("$basePath/$dataDump") . ' -a --disable-triggers -t resources -t identifiers -t relations -t metadata -t spatial_search -t full_text_search -t id_seq -t mid_seq -t spid_seq -t ftsid_seq' . $dbConn);

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
    foreach ([$dataDump, $imgsDump, $cfgDump] as $i) {
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

    $dbUser = $argv[2] ?? $user;
    $dbConn = explode("\n", file_get_contents($_SERVER['HOME'] . '/.pgpass'));
    $dbConn = array_map(fn($x) => explode(":", $x), $dbConn);
    $dbConn = array_filter($dbConn, fn($x) => ($x[3] ?? '') === $dbUser);
    $dbConn = reset($dbConn);
    if (!empty($dbConn)) {
        $dbConn = '' .
            (isset($dbConnParam['host']) ? " -h '" . $dbConnParam['host'] . "'" : '') .
            (isset($dbConnParam['port']) ? " -p '" . $dbConnParam['port'] . "'" : '') .
            " -U '$dbUser'" .
            (isset($dbConnParam['dbname']) ? " '" . $dbConnParam['dbname'] . "'" : '') ;
    }

    echo "### Removing old metadata\n";
    system("psql $dbConn -c 'TRUNCATE resources CASCADE; TRUNCATE metadata_history;'");
    echo "### Importing new data\n";
    system("psql -f " . escapeshellarg($dataDump) . $dbConn);

    $oldCfg    = json_decode(json_encode(yaml_parse_file($cfgDump)));
    $oldIdBase = $oldCfg->rest->urlBase . $oldCfg->rest->pathBase;
    $newIdBase = $cfg->rest->urlBase . $cfg->rest->pathBase;
    echo "### Migrating identifiers from $oldIdBase to $newIdBase\n";
    $query     = $pdo->prepare("UPDATE identifiers SET ids = replace(ids, ?, ?) WHERE ids LIKE ?");
    $query->execute([$oldIdBase, $newIdBase, "$oldIdBase%"]);
    echo "### Restoring thumbnails\n";
    $imgsDump = getcwd() . "/$imgsDump";
    chdir($cfg->storage->dir);
    system("tar -x -f " . escapeshellarg($imgsDump));
    echo "### Migration finished\n\n";
}

