# Docker orchestration for EEA main portal (www-replica-prod)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher Compose](http://docs.rancher.com/rancher/rancher-compose/)
* Dedicated Rancher Environment (recommended)

## Installation

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Add deployment infrastructure within your cloud provider

    $ cd deploy/infrastructure

Add required info within `.cloudaccess` and `.secret` needed by [eeacms/os-docker-vm](https://github.com/eea/eea.docker.openstack.host#usage)

    $ vim .cloudaccess
    $ vim .secret

The `base-flavors.yml` contains the basic flavors specifications for the infrastructure. Make sure that you are using the correct tag for eeacms/os-docker-vm.

The `docker-compose.yml` extends the base-flavors.yml to create specific number of VMs. Adjust the `INSTANCE_NAME` in order to give the unique names and according to your naming conventions.

To create the VMs run the following command and note the output:

    $ docker-compose up

After around 5 min you should have all the VMs created on the specified cloud provider tenant and region.

### Register above hosts within Rancher

* Register dedicated `fileserver` hosts with labels `nfs-server=yes` (NFS Server)
* Register dedicated `db` hosts with labels: `www=yes`, `db=yes` (PostgreSQL)
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
    $ rancher-compose -e ../production-replica.env up -d

### Start SYNC stack (sync blobs and static resources from production/to testing)

    $ cd deploy/www-sync
    $ rancher-compose -e ../production-replica.env up -d

* Make sure that `Production` can connect to `rsync-server` (Blob and static resources sync)
* Make sure that `Production PostgreSQL` can connect to `rsync-server`. (PostgreSQL upstream replica)
* Make sure that `rsync-client` can connect to `rsync-server on Devel tenant`. (DB pg_dump, blobs and static-resources sync)

### Sync database

    $ ssh <postgresql master on production>
    $ cd /var/lib/pgsql/9.4/data
    $ vim ecs-backup.sh
    $ ./ecs-backup.sh

### Start DB stack (postgres)

    $ cd deploy/www-db
    $ rancher-compose -e ../production-replica.env up -d

### Start EEA Application stack (plone backends, memcache, varnish, apache)

    $ cd deploy/www-eea
    $ rancher-compose -e ../production-replica.env up -d

### Add Load-Balancer (optional if not done already by other stack)

Within Rancher UI add Rancher Load Balancer for `www-frontend/apache` containers
scheduled on hosts with label `public=yes`

## Upgrade

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Upgrade Backend stack (plone instances, async workers)

Update `KGS_VERSION` within `deploy/production-replica.env`

    $ vim deploy/production-replica.env

Upgrade:

    $ cd deploy/www-eea
    $ rancher-compose -e ../production-replica.env pull
    $ rancher-compose -e ../production-replica.env up -d --upgrade --interval 300000 --batch-size 1

If the upgrade went well, finish the upgrade with:

    $ rancher-compose -e ../production-replica.env up -d --confirm-upgrade

Otherwise, roll-back:

    $ rancher-compose -e ../production-replica.env up -d --rollback
