# Docker orchestration for EEA main portal (staging)

Docker orchestration for EEA main portal services


## Pre-requirements

* [Rancher Compose](http://docs.rancher.com/rancher/rancher-compose/)
* Add dedicated Rancher Environment called `Staging-WWW`
* Register min 3 hosts with label `fileserver=yes` and with a `256G` volume mounted to `/var/lib/docker/volumes`
* Register min 2 hosts with label: `db=yes`
* Register min 2 hosts with label: `backend=yes`
* Register min 2 hosts with label: `frontend=yes`
* Add label `public=yes` to hosts with public IPs.
* Make sure that you have a reachable PostgreSQL host serving the EEA site db.
* Update deployment settings to `deploy/staging.txt` (including PostgreSQL IP address).


## Installation

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www


### Start GlusterFS server (shared blobs and static resources)

    $ cd deploy/glusterfs
    $ rancher-compose -e ../staging.env up -d

### Start Convoy GlusterFS driver

    $ cd deploy/convoy-gluster
    $ rancher-compose -e ../staging.env up -d

### Start SYNC stack (sync blobs and static resources from production/to testing)

    $ cd deploy/www-sync
    $ rancher-compose -e ../staging.env up -d

### Start DB stack (postgres, memcached)

    $ cd deploy/www-db
    $ rancher-compose -e ../staging.env up -d

### Start Backend stack (plone instances, async workers)

    $ cd deploy/www-backend
    $ rancher-compose -e ../staging.env up -d

### Start Frontend stack (apache, varnish, haproxy)

    $ cd deploy/www-frontend
    $ rancher-compose -e ../staging.env up -d


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
