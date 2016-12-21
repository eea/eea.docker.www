# Docker orchestration for EEA main portal (www-prod)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher Compose](http://docs.rancher.com/rancher/rancher-compose/)
* Dedicated Rancher Environment (recommended)

## Installation

On your laptop:

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Register hosts within Rancher via Rancher UI

* Register dedicated `cache` hosts with labels: `www=yes`, `cache=yes` (Memcache)
* Register dedicated `backend` hosts with label: `www=yes`, `backend=yes` (Plone)
* Register dedicated `frontend` hosts with label: `www=yes`, `frontend=yes` (Varnish, Apache)
* Add Public IP to one `frontend` and label it within Rancher UI with `sync=yes` and `public=yes` (Sync, Load Balancer)

### Setup NFS server to be used with Rancher-NFS (shared blobs and static resources)

    $ ssh <fileserver-ip>
    $ docker run --rm -v nfs:/data alpine touch /data/test
    $ echo "/var/lib/docker/volumes/nfs/_data 10.128.0.0/24(rw,insecure,no_root_squash) 10.42.0.0/16(rw,insecure,no_root_squash)" >> /etc/exports
    $ systemctl enable rpcbind nfs-server
    $ systemctl restart rpcbind nfs-server

### Access rights

To enable Rancher Compose to launch services in a Rancher instance, you’ll need to set environment variables or pass
these variables as an option in the Rancher Compose command.
See related [Rancher documentation](https://docs.rancher.com/rancher/v1.0/en/configuration/api-keys/#adding-environment-api-keys)
on how to obtain your Rancher API Keys.

Thus on your laptop:

* Add Rancher specific environment variables (API URL, access and secret key) and the other secrets (for traceview, rabbitmq, etc.):

        $ cd deploy
        $ cp .secret.example .secret.production
        $ vim .secret.production

* And make them available:

        $ source .secret.production

* Make sure you're deploying to the right Rancher Environment:

        $ env | grep RANCHER

Make sure you've provided the right credentials for Traceview and RabbitMQ:

    $ env | grep TRACEVIEW
    $ env | grep RABBITMQ


### Setup NFS volumes support

From `Rancher Catalog > Library` deploy `Rancher NFS` stack:
* NFS_SERVER: `10.1.20.90`
* MOUNT_DIR: `/www_zodbblobstorage`
* MOUNT_OPTS: `noatime,sec=sys,timeo=600,retrans=2`


### Start SYNC stack (sync blobs and static resources from production/to staging)

    $ cd deploy/www-sync
    $ rancher-compose -e ../production.env pull
    $ rancher-compose -e ../production.env up -d

* Make sure that `rsync-client` can connect to `rsync-server on www-prod-replica tenant`. (blobs and static-resources sync)

### Start DB stack (PostgreSQL Database)

    $ cd deploy/www-db
    $ rancher-compose -e ../production.env -f production.yml up -d

### Start EEA Application stack (plone backends, memcache, varnish, apache)

    $ cd deploy/www-eea
    $ source ../.secret.production

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

Add your Rancher API Keys to `.secret.production` file (see related [Rancher documentation](https://docs.rancher.com/rancher/v1.0/en/configuration/api-keys/#adding-environment-api-keys)
on how to obtain them):

    $ cp .secret.example .secret.production
    $ vim .secret.production

and make them available:

    $ source .secret.production

Make sure you're upgrading within the right Rancher Environment:

    $ env | grep RANCHER

Make sure you've provided the right credentials for Traceview and RabbitMQ:

    $ env | grep TRACEVIEW
    $ env | grep RABBITMQ

Update `KGS_VERSION` within `deploy/production.env`

    $ vim deploy/production.env

Upgrade:

    $ cd deploy/www-eea
    $ rancher-compose -e ../production.env pull
    $ rancher-compose -e ../production.env up -d --upgrade --batch-size=1

If the upgrade went well, finish the upgrade with:

    $ rancher-compose -e ../production.env up -d --confirm-upgrade

Otherwise, roll-back:

    $ rancher-compose -e ../production.env up -d --rollback

## Debug

On your laptop:

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

Start debug stack:

    $ cd deploy/www-debug
    $ rancher-compose -e ../production.env up -d

Now, via Rancher UI:

* Find `www-debug_debug_1` container
* **Execute Shell**
* **Start** Plone inside container: `$ bin/instance start` or `$ bin/instance fg`
* Within `www-debug` stack find `exposed` port for `8080` and **click** on it.
* **Stop** Plone inside debugging container **when you're done**: `$ bin/instance stop`
