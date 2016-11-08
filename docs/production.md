# Docker orchestration for EEA main portal (www-prod)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher Compose](http://docs.rancher.com/rancher/rancher-compose/)
* Dedicated Rancher Environment (recommended)

## Installation

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Register hosts within Rancher

* Register dedicated `cache` hosts with labels: `www=yes`, `cache=yes` (Memcache)
* Register dedicated `backend` hosts with label: `www=yes`, `backend=yes` (Plone)
* Register dedicated `frontend` hosts with label: `www=yes`, `frontend=yes` (Varnish, Apache)
* Add Public IP to one `frontend` and label it within Rancher UI with `sync=yes` and `public=yes` (Sync, Load Balancer)

### Setup NFS server to be used with ConvoyNFS (shared blobs and static resources)

    $ ssh <fileserver-ip>
    $ docker run --rm -v nfs:/data alpine touch /data/test
    $ echo "/var/lib/docker/volumes/nfs/_data 10.128.0.0/24(rw,insecure,no_root_squash) 10.42.0.0/16(rw,insecure,no_root_squash)" >> /etc/exports
    $ systemctl enable rpcbind nfs-server
    $ systemctl restart rpcbind nfs-server

### Start Convoy NFS driver

Back to your laptop

    $ cd deploy/www-nfs
    $ rancher-compose -e ../production.env pull
    $ rancher-compose -e ../production.env up -d

### Start SYNC stack (sync blobs and static resources from production/to staging)

    $ cd deploy/www-sync
    $ rancher-compose -e ../production.env pull
    $ rancher-compose -e ../production.env up -d

* Make sure that `rsync-client` can connect to `rsync-server on www-prod-replica tenant`. (blobs and static-resources sync)


### Start EEA Application stack (plone backends, memcache, varnish, apache)

    $ cd deploy/www-eea
    $ rancher-compose -e ../production.env pull
    $ rancher-compose -e ../production.env up -d

### Add Load-Balancer (optional if not done already by other stack)

Within Rancher UI add Rancher Load Balancer for `www-frontend/apache` containers
scheduled on hosts with label `public=yes`

## Upgrade

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Upgrade Backend stack (plone instances, async workers)

Update `KGS_VERSION` within `deploy/production.env`

    $ vim deploy/production.env

Upgrade:

    $ cd deploy/www-eea
    $ rancher-compose -e ../production.env pull
    $ rancher-compose -e ../production.env up -d --upgrade

If the upgrade went well, finish the upgrade with:

    $ rancher-compose -e ../production.env up -d --confirm-upgrade

Otherwise, roll-back:

    $ rancher-compose -e ../production.env up -d --rollback
