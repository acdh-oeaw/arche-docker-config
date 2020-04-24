# ACDH repo docker image config

This repository contains sample configurations for the ACDH repo Docker deployment provided at https://github.com/acdh-oeaw/arche-docker

Detaching config from the runtime environment configuration allows to distribute the deployment environment updates easily as they are version separately from particular configurations.

The deployment environment can be instructed about the configuration repository location (and branch) using environment variables - see the https://github.com/acdh-oeaw/arche-docker README.

This repository has multiple branches implementing different configurations.

## Developing your own config

 It has a following structure:

* `yaml` - directory with config files parts. In this particular setup configuration parts are merged together for particular services' configuration by corresponding scripts in the `run.d` directory. When deploying don't forget to copy `yaml/local.yaml.sample` to `yaml/local.yaml` and adjust its content.
* `composer.json` - describes PHP dependencies of the repository components. If you add your own PHP components to the repository deployment, you may consider extending it. These dependencies are automatically installed into `/home/www-data/vendor` and updated on every repository container start.
* `run.d` - allows you to add initialization scripts to be run before the supervisord is started.
* `supervisord.conf.d` - allows you to add additional services definition. All files with names ending with `.conf` are included in the container's supervisord config.
* `initScripts` - allows you to add scripts to be run after the whole repository initialization. All executable files in this directory will be run on every repository startup (see diagram below). Use [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)#Syntax) syntax to make your scripts executable.
* `sites-enabled` - allows you to adjust the Apache settings.

## How the config is processed during repository startup?

![Repository startup diagram](https://acdh-oeaw.github.io/arche-docs/diagrams/docker-init.png)
