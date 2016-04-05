# Docker orchestration for EEA main portal (staging)

Docker orchestration for EEA main portal services


## Pre-requirements

* [Rancher Compose](http://docs.rancher.com/rancher/rancher-compose/)
* Add dedicated Rancher Environment called `Staging-WWW`
* Register hosts within this Rancher Environment and label them with `db=yes`, `backend=yes`, `frontend=yes`
* Add `blobs` and `www-static-resources` to a NFS Server visible by these hosts.
* Update deployment settings to `deploy/staging.txt`


## Installation

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Setup NFS server (shared blobs and static resources)

    $ cd deploy/convoy-nfs
    $ rancher-compose -e ../staging.env up -d

### Start DB stack (postgres, memcached)

    $ cd deploy/www-db
    $ rancher-compose -e ../staging.env up -d

### Start Backend stack (plone instances, async workers)

    $ cd deploy/www-backend
    $ rancher-compose -e ../staging.env up -d

### Start Frontend stack (apache, varnish, haproxy)

    $ cd deploy/www-frontend
    # rancher-compose -e ../staging.env up -d


## Upgrade

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Upgrade Backend stack (plone instances, async workers)

Update `KGS_VERSION` within `deploy/staging.env`

    $ vim deploy/staging.env

Upgrade:

    $ cd deploy/www-backend
    $ rancher-compose -e ../staging.env up -d --upgrade --interval 60000 --batch-size 1

If the upgrade went well, finish the upgrade with:

    $ rancher-compose -e ../staging.env up -d --confirm-upgrade

Otherwise, roll-back:

    $ rancher-compose -e ../staging.env up -d --rollback


## Access

[staging.eea.europa.eu](http://staging.eea.europa.eu)
