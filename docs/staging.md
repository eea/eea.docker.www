# Docker orchestration for EEA main portal (staging)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher Compose](http://docs.rancher.com/rancher/rancher-compose/)
* Dedicated Rancher Environment

## Installation

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Add deployment infrastructure within your cloud provider

    $ cd deploy/infrastructure

Add required info within `.cloudaccess` and `.secret` needed by [eeacms/os-docker-vm](https://github.com/eea/eea.docker.openstack.host#usage)

    $ vim .cloudaccess
    $ vim .secret

Create VMs (adjust `PREFIX` and `SUFFIX` according to deployment tenant/region and next available host name):

    $ PREFIX=dev-mil SUFFIX=10 ./setup.sh

The above command will create the following VMs:

    dev-mil-10 (fileserver)
    dev-mil-11 (fileserver)
    dev-mil-12 (fileserver)
    dev-mil-13 (db)
    dev-mil-14 (db)
    dev-mil-15 (backend)
    dev-mil-16 (backend)
    dev-mil-17 (backend)
    dev-mil-18 (backend)
    dev-mil-19 (frontend)
    dev-mil-20 (frontend)

SSH on these machines and prepare them for Rancher registration:

    $ sudo bash
    $ hostnamectl set-hostname dev-mil-NN
    $ mkfs.ext4 /dev/vdc
    $ echo "/dev/vdc /var/lib/docker/volumes ext4    defaults        1 2" >> /etc/fstab
    $ /root/run-docker-storage-setup-once.sh

### Register above hosts within Rancher

* Register dedicated `fileserver` hosts with label `fileserver=yes` (GlusterFS)
* Register dedicated `db` hosts with label: `db=yes` (Memcache and PostgreSQL)
* Register dedicated `backend` hosts with label: `backend=yes` (Plone)
* Register dedicated `frontend` hosts with label: `frontend=yes` (Varnish, Apache)
* Add Public IP to one `frontend` and label it within Rancher UI with `public=yes` (Sync, Load Balancer)

### Start GlusterFS server (shared blobs and static resources)

    $ cd deploy/glusterfs
    $ rancher-compose -e ../staging.env up -d

### Start Convoy GlusterFS driver

    $ cd deploy/convoy-gluster
    $ rancher-compose -e ../staging.env up -d

### Start SYNC stack (sync blobs and static resources from production/to testing)

    $ cd deploy/www-sync
    $ rancher-compose -e ../staging.env up -d

Make sure that `Production` can connect to `rsync-server`.
Make sure that `rsync-client` can connect to `Testing/Development`.

### Start DB stack (postgres)

    $ cd deploy/www-db
    $ rancher-compose -e ../staging.env up -d

### Start EEA Application stack (plone backends, memcache, varnish, apache)

    $ cd deploy/www-eea
    $ rancher-compose -e ../staging.env up -d

### Add Load-Balancer (optional if not done already by other stack)

Within Rancher UI add Rancher Load Balancer for `www-frontend/apache` containers
scheduled on hosts with label `public=yes`

## Upgrade

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Upgrade Backend stack (plone instances, async workers)

Update `KGS_VERSION` within `deploy/staging.env`

    $ vim deploy/staging.env

Upgrade:

    $ cd deploy/www-eea
    $ rancher-compose -e ../staging.env pull
    $ rancher-compose -e ../staging.env up -d --upgrade --interval 60000 --batch-size 1

If the upgrade went well, finish the upgrade with:

    $ rancher-compose -e ../staging.env up -d --confirm-upgrade

Otherwise, roll-back:

    $ rancher-compose -e ../staging.env up -d --rollback
