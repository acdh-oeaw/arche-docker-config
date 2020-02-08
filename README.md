# ACDH repo docker image config

This repository contains sample configurations for the ACDH repo Docker deployment provided at https://github.com/zozlak/acdh-repo-docker

Detaching config from the runtime environment configuration allows to distribute the deployment environment updates easily as they are version separately from particular configurations.

The deployment environment can be instructed about the configuration repository location (and branch) using environment variables - see the https://github.com/zozlak/acdh-repo-docker README.

