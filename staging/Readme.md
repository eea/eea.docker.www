# Docker orchestration for EEA main portal (staging)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher Compose](http://docs.rancher.com/rancher/rancher-compose/)
* Add dedicated Rancher Environment called `Staging-WWW`
* Register hosts within this Rancher Environment and label them with `db=yes`, `backend=yes`, `frontend=yes`
* Add `blobs` and `www-static-resources` to a NFS Server visible by these hosts.
* Update NFS Server settings to `staging.txt`

## Installation

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

## Setup NFS server (shared blobs and static resources)

    $ cd convoy-nfs
    $ rancher-compose -e staging.txt up -d

## Start DB stack (postgres, memcached)

    $ cd staging/www-db
    $ rancher-compose up -d

## Start Backend stack (plone instances, async workers)

    $ cd staging/www-backend
    $ rancher-compose up -d

## Start Frontend stack (apache, varnish, haproxy)

    $ cd staging/www-frontend
    # rancher-compose up -d

## Access

[staging.eea.europa.eu](http://staging.eea.europa.eu)
