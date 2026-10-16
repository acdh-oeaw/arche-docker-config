#!/bin/bash
if [ ! -d /home/www-data/gui/.git ]; then
    su -w http_proxy,https_proxy -l www-data -c 'git clone https://github.com/nczirjak-acdh/arche-gui-backend-api.git /home/www-data/gui' || exit 1
fi


su -l www-data -c "ln -sfn /home/www-data/gui/public /home/www-data/docroot/guiApi"

# Create the basic .env file before composer run
: "${PG_USER:?PG_USER is required}" "${PG_PSWD:?PG_PSWD must contain the password for PG_USER}" \
  "${PG_DBNAME:?PG_DBNAME is required}" "${PG_HOST:?PG_HOST is required}" "${PG_PORT:?PG_PORT is required}"
if [ ! -f /home/www-data/gui/.env ]; then
    su -l www-data -c 'umask 077; cat > /home/www-data/gui/.env' <<'ENV' || exit 1

###> symfony/framework-bundle ###
APP_ENV=dev
APP_SECRET=
APP_DEBUG=1
APP_SHARE_DIR=var/share
###< symfony/framework-bundle ###

###> symfony/routing ###
# Configure how to generate URLs in non-HTTP contexts, such as CLI commands.
# See https://symfony.com/doc/current/routing.html#generating-urls-in-commands
DEFAULT_URI=http://localhost
###< symfony/routing ###

DB_USER=""
DB_PASS=""
DB_NAME=""
DB_HOST=""
DB_PORT=""

###> nelmio/cors-bundle ###
CORS_ALLOW_ORIGIN='^https?://(localhost|127\.0\.0\.1)(:[0-9]+)?$'
###< nelmio/cors-bundle ###
ENV
fi

# Add the DB settings into the file
export PG_USER PG_PSWD PG_DBNAME PG_HOST PG_PORT
su -w PG_USER,PG_PSWD,PG_DBNAME,PG_HOST,PG_PORT -l www-data -c 'php' <<'PHP' || exit 1
<?php
$path = '/home/www-data/gui/.env';
$env = file_get_contents($path);
if ($env === false) {
    throw new RuntimeException('Cannot read Symfony .env');
}

foreach (['DB_USER' => 'PG_USER', 'DB_PASS' => 'PG_PSWD', 'DB_NAME' => 'PG_DBNAME', 'DB_HOST' => 'PG_HOST', 'DB_PORT' => 'PG_PORT'] as $key => $source) {
    $value = strtr(getenv($source), ["\\" => "\\\\", '"' => '\\"', '$' => '\\$', "\n" => '\\n', "\r" => '\\r']);
    $line = $key . '="' . $value . '"';
    $env = preg_replace_callback('/^[ \t]*(?:export[ \t]+)?' . $key . '[ \t]*=.*$/m', fn() => $line, $env, -1, $count);
    if ($count === 0) {
        $env .= "\n" . $line . "\n";
    }
}
if (!chmod($path, 0600) || file_put_contents($path, $env) === false) {
    throw new RuntimeException('Cannot update Symfony .env');
}
PHP


su -w http_proxy,https_proxy -l www-data -c 'cd /home/www-data/gui && APP_ENV=prod APP_DEBUG=0 composer install --no-dev --no-interaction --optimize-autoloader' || exit 1

CMD=/home/www-data/vendor/zozlak/yaml-merge/bin/yaml-edit.php
CFGD=/home/www-data/config/yaml
rm -f /home/www-data/gui/src/arche-config/config-gui.yaml $CFGD/config-gui.yaml
su -l www-data -c "$CMD \\
    --src $CFGD/schema.yaml \\
    --src $CFGD/openaire.yaml \\
    --src $CFGD/smartSearch.yaml \\
    --src $CFGD/repo.yaml --srcPath '$.metadataManagment.nonRelationProperties' --targetPath '$.metadataManagment.nonRelationProperties' \\
    --src $CFGD/repo.yaml --srcPath '$.accessControl.publicRole' --targetPath '$.publicRole' \\
    --src $CFGD/config-db.yaml --srcPath '$.dbConnStr.gui' --targetPath '$.dbConnStr' \\
    --src $CFGD/local.yaml \\
    $CFGD/config-gui.yaml"
su -l www-data -c "ln -s $CFGD/config-gui.yaml /home/www-data/gui/src/arche-config/config-gui.yaml"

