# Docker orchestration for EEA main portal (staging)

Docker orchestration for EEA main portal services

## Installation

    $ git clone https://github.com/eea/eea.docker.www.git /var/local/deploy/eea.docker.www
    $ cd /var/local/deploy/eea.docker.www/staging

## Start

    $ docker-compose up -d

See everything is up-and-running

    $ docker-compose ps

## Access

[staging.eea.europa.eu](http://staging.eea.europa.eu)


## Upgrade

    $ docker-compose pull
    $ docker-compose stop
    $ docker-compose -f docker-remove.yml rm -v
    $ docker-compose up -d --no-recreate
    $ docker-compose logs
