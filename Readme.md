# Docker orchestration for EEA main portal

Docker orchestration for EEA main portal services


## Installation

1. Install [Docker](https://www.docker.com/).

2. Install [Docker Compose](https://docs.docker.com/compose/).

## Usage

    $ sudo bash
    $ useradd -u 500 zope-www
    $ usermod -a -G docker zope-www
    $ ln -s /usr/local/bin/docker-compose /bin/docker-compose
    $ su zope-www

    $ cd /var/local/deploy
    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Staging

    $ cd /var/local/deploy/eea.docker.www/staging

* Start

    $ cd staging
    $ docker-compose up -d
    $ docker-compose logs

### Development

    $ cd /var/local/deploy/eea.docker.www/devel

* Get source code

    $ docker-compose up source_code

* Setup database

    $ cd devel
    $ docker-compose stop
    $ docker-compose rm -v
    $ docker-compose up -d postgres

    $ cp /var/zodb/pg_dump/datafs.gz /var/local/deploy/eea.docker.www/devel/backup/
    $ docker exec -it devel_postgres_1 bash
      $ gunzip -c /postgresql.backup/datafs.gz | psql -U zope datafs
      $ exit

* Start application

    $ cd devel
    $ docker-compose up -d --no-recreate

## Upgrade

    $ cd devel
    $ docker-compose pull
    $ docker-compose stop
    $ docker-compose -f docker-remove.yml rm -v
    $ docker-compose up -d --no-recreate
    $ docker-compose logs

## Copyright and license

The Initial Owner of the Original Code is European Environment Agency (EEA).
All Rights Reserved.

The Original Code is free software;
you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later
version.

## Funding

[European Environment Agency (EU)](http://eea.europa.eu)
