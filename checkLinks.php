#!/usr/bin/php
<?php
use GuzzleHttp\Psr7\Request;
use GuzzleHttp\Psr7\Response;
use GuzzleHttp\Pool;

include '/home/www-data/vendor/autoload.php';

$param = ['dbConn' => 'pgsql:', 'timeout' => 10, 'parallel' => 5, 'retry400WithGet' => false, 'help' => false, 'progress' => false, 'auth' => '', 'authNmsp' => ''];
$helpStr = "$argv[0] [--timeout seconds] [--parallel N] [--dbConn PDOconnString] [--retryGet] [--auth user:pswd] [--authNmsp authIsUsedOnlyInThisNamespace] [--help]\n\nSearches arche-core database for broken URLs.\nAll literal values of type xsd:anyURI are checked.\n\ndefault parameter values: dbConn: '" . $param['dbConn'] . "', timeout: " . $param['timeout'] . ", parallel: " . $param['parallel'] . "\n\n";
foreach ($argv as $n => $v) {
    if (in_array($v, ['--timeout', '--parallel', '--dbConn', '--auth', '--authNmsp'])) {
        if (!isset($argv[$n + 1])) {
            echo $helpStr;
            exit();
        }
        $param[substr($v, 2)] = $argv[$n + 1];
    } else if (in_array($v, ['--retry400WithGet', '--help', '--progress'])) {
        $param[substr($v, 2)] = true;
    }
}
if ($param['help']) {
    echo $helpStr;
    exit();
}

$t0 = microtime(true);
$opts = [
    'http_errors'     => false,
    'timeout'         => $param['timeout'],
    'allow_redirects' => [
        'max'             => 10,
        'strict'          => false,
        'track_redirects' => true,
    ],
];
$client     = new GuzzleHttp\Client($opts);
$clientAuth = null;
if (!empty($param['auth'])) {
    $opts['auth'] = explode(':', $param['auth']);
    $clientAuth   = new GuzzleHttp\Client($opts);
}
$pdo = new PDO($param['dbConn']);
$count = $pdo->query("SELECT count(DISTINCT value) FROM metadata WHERE type = 'http://www.w3.org/2001/XMLSchema#anyURI'")->fetchColumn();
unset($param['dbConn'], $param['help']);
$param['auth'] = !empty($param['auth']) ? '***' : '';
echo "@ Checking for broken URLs (" . date('Y-m-d H:i:s') . ") $count URLs to check\n@ " . json_encode($param, JSON_UNESCAPED_SLASHES) . "\n\n";

$urls = [];
function fetchRequests($pdo) {
    global $urls, $param, $count, $t0;
    $query = $pdo->query("SELECT DISTINCT value FROM metadata WHERE type = 'http://www.w3.org/2001/XMLSchema#anyURI'");
    $n = 0;
    while ($i = $query->fetchColumn()) {
        $urls[(string)$n] = $i;
        yield new Request('HEAD', $urls[(string)$n]);
        $n++;
        if ($param['progress'] && $n % 1000 === 0) {
            $t = intval(microtime(true) - $t0);
            fwrite(STDERR, "# $n / $count (" . intval(100 * $n / $count) . "%) $t s ETA " . intval($t / $n * $count - $t) . " s\n");
        }
    }
}
$broken  = [];
$failing = [];
$pool = new Pool($client, fetchRequests($pdo), [
    'concurrency' => $param['parallel'], 
    'fulfilled' => function(Response $response, $index) {
        global $urls, $broken, $param, $client, $clientAuth;
        $index  = (string) $index;
        $url    = $urls[$index];
        $status = $response->getStatusCode();
        if ($status >= 400 && $status < 500 && $param['retry400WithGet']) {
            $response = $client->send(new Request('GET', $url));
            $status = $response->getStatusCode();
        }
        if (in_array($status, [401, 403]) && $clientAuth !== null) {
            $redirects = $response->getHeader('X-Guzzle-Redirect-History');
            $lastUrl = count($redirects) > 0 ? end($redirects) : $url;
            if (str_starts_with($lastUrl, $param['authNmsp'])) {
                $response = $clientAuth->send(new Request('HEAD', $lastUrl));
                $status   = $response->getStatusCode();
            }
        }
        if ($status < 200 || $status >= 400) {
            if (!isset($broken[(string) $status])) {
                $broken[(string) $status] = [];
            }
            $broken[(string) $status][$url] = array_combine($response->getHeader('X-Guzzle-Redirect-History'), $response->getHeader('X-Guzzle-Redirect-Status-History'));
        }
	unset($urls[$index]);
    },
    'rejected' => function(Exception $reason, $index) {
        global $urls, $failing;
        $index = (string) $index;
        $failing[$urls[$index]] = $reason->getMessage();
        unset($urls[$index]);
    },
]);
$promise = $pool->promise();
$promise->wait();


$resQuery = $pdo->prepare("SELECT string_agg(id::text || ' -> ' || property, E'\n' ORDER BY id, property) FROM metadata WHERE substring(value, 1, 1000) = ?");
function reportResources(string $url): string {
    global $resQuery;
    $resQuery->execute([$url]);
    return "    " . str_replace("\n", "\n    ", (string) $resQuery->fetchColumn());
}

if (count($failing) > 0) {
    echo "# Failed to make a request:\n\n";
    foreach ($failing as $url => $reason) {
        echo "* $url => $reason\n" . reportResources($url) . "\n";
    }
}
// move 403 to the bottom
$codes = array_filter(array_keys($broken), fn($x) => intval($x) !== 403);
sort($codes);
if (isset($broken['403'])) {
    $codes[] = '403';
}
// print
foreach ($codes as $code) {
    $urls = $broken[$code];
    echo "\n# HTTP code $code:\n\n";
    foreach ($urls as $url => $redirects) {
        $other = '';
        foreach ($redirects as $rUrl => $rStatus) {
            $other .= " => $rStatus $rUrl";
        }
        echo "* $url$other\n" . reportResources($url) . "\n";
    }
}

echo "\n@ Total time: " . (microtime(true) - $t0) . " s\tmemory usage: " . (memory_get_peak_usage() / 1024 / 1024) . " MB\n";

