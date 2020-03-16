# ACDH repo docker image config

This repository contains sample configurations for the ACDH repo Docker deployment provided at https://github.com/acdh-oeaw/arche-docker

Detaching config from the runtime environment configuration allows to distribute the deployment environment updates easily as they are version separately from particular configurations.

The deployment environment can be instructed about the configuration repository location (and branch) using environment variables - see the https://github.com/acdh-oeaw/arche-docker README.

This repository has multiple branches implementing different configurations.

## Developing your own config

 It has a following structure:

* `config.yaml` - the repository configuration file. You must adjust at least the `rest->urlBase` and `rest->pathBase` settings but you may want to tune up many more. Follow the comments inside the file.
* `composer.json` - describes PHP dependencies of the repository components. If you add your own PHP components to the repository deployment, you may consider extending it. These dependencies are automatically installed into `/home/www-data/docroot/vendor` and updated on every repository container start.
* `run.d` - allows you to add initialization scripts to be run before the supervisord is started.
* `supervisord.conf.d` - allows you to add additional services definition. All files with names ending with `.conf` are included in the container's supervisord config.
* `initScripts` - allows you to add scripts to be run after the whole repository initialization. All files in this directory should be executable. If they are scripts, use the [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)#Syntax) syntax to provide the correct interpreter. These scripts are run on every container start.
* `sites-enabled` - allows you to adjust the Apache settings.

