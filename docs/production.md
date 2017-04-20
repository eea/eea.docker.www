# Docker orchestration for EEA main portal (www-prod)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher CLI](https://docs.rancher.com/rancher/v1.2/en/cli/)
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
* **Make sure NFSv4 support is properly configured on these hosts. See** [ticket #80428](https://taskman.eionet.europa.eu/issues/80428#note-5)

### Setup NFS server to be used with Rancher-NFS (shared blobs and static resources)

        $ ssh <fileserver-ip>
        $ docker run --rm -v nfs:/data alpine touch /data/test
        $ echo "/var/lib/docker/volumes/nfs/_data 10.128.0.0/24(rw,insecure,no_root_squash) 10.42.0.0/16(rw,insecure,no_root_squash)" >> /etc/exports
        $ systemctl enable rpcbind nfs-server
        $ systemctl restart rpcbind nfs-server

### Access rights

To enable Rancher CLI to launch services in a Rancher instance, you’ll need to configure it
See related [Rancher documentation](http://docs.rancher.com/rancher/v1.3/en/api/v2-beta/access-control/)
on how to obtain your Rancher API Keys. Thus:

1. Via Rancher UI:

    * Go to **API Tab** add an **Account API Key**

2. Then on your laptop configure Rancher CLI:

        $ rancher --config ~/.rancher/rancher.prod.json config
        $ cp ~/.rancher/rancher.prod.json ~/.rancher/cli.json

3. Now **make sure that you're deploying within the right environment**:

        $ rancher config -p

4. Application passwords and secrets keys:

        $ cd deploy
        $ cp .secret.example .secret
        $ vim .secret

5. Make them available

        $ source .secret

6. Make sure you've provided the right credentials for `Traceview` and `RabbitMQ`:

        $ env | grep TRACEVIEW
        $ env | grep RABBITMQ


### Setup NFS/DB volumes

* From **Rancher Catalog > Library** deploy **Rancher NFS** stack:
  * **NFS_SERVER**: `10.1.20.90`
  * **MOUNT_DIR**: `/www_zodbblobstorage`
  * **MOUNT_OPTS**: `noatime,sec=sys,timeo=600,retrans=2`
* From **Rancher Catalog > EEA** deploy **EEA WWW - Volumes** stack


### Start SYNC stack (sync blobs and static resources from production/to staging)

        $ cd deploy/www-sync
        $ rancher up -d -e ../production.env

* Make sure that `rsync-client` can connect to `rsync-server on www-prod-replica tenant`. (blobs and static-resources sync)

### Start DB stack (PostgreSQL Database)

        $ cd deploy/www-db
        $ rancher up -d -e ../production.env -f production.yml

### Start EEA Application stack (plone backends, memcache, varnish, apache)

        $ cd deploy/www-eea
        $ source ../.secret

        $ rancher up -d -e ../production.env

### Add Load-Balancer

Within `Rancher UI > Infrastrucutre > Certificates` add SSL Certificate named `EEA`, then on your laptop:

        $ cd deploy/www-lb
        $ rancher up -d -e ../production.env


## Upgrade

### Upgrade Backend stack (plone instances, async workers)

1. On your laptop

        $ git clone https://github.com/eea/eea.docker.www.git
        $ cd eea.docker.www/deploy

2. Configure Rancher CLI:

        $ rancher --config ~/.rancher/rancher.prod.json config
        $ cp ~/.rancher/rancher.prod.json ~/.rancher/cli.json

3. Now **make sure that you're deploying within the right environment**:

        $ rancher config -p

4. Make application passwords and secrets keys available:

        $ source .secret

5. Make sure you've provided the right credentials for `Traceview` and `RabbitMQ`:

        $ env | grep TRACEVIEW
        $ env | grep RABBITMQ

6. Update `KGS_VERSION` within `deploy/production.env`

        $ git pull
        $ vim production.env

7. Upgrade:

        $ cd www-eea
        $ rancher up -d -e ../production.env --upgrade --batch-size 1

8. If the upgrade went well, finish the upgrade with:

        $ rancher up -d -e ../production.env --confirm-upgrade
        $ git add production.env
        $ git commit
        $ git push

9. Otherwise, roll-back:

        $ rancher up -d -e ../production.env --rollback

## Debug

1. On your laptop:

        $ git clone https://github.com/eea/eea.docker.www.git
        $ cd eea.docker.www

2. Make sure that you're deploying within the right environment:

        $ rancher config

3. Start debug stack:

        $ cd deploy/www-debug
        $ rancher up -d -e ../production.env

4. Start Plone instance in `debug` mode

        $ rancher exec -it www-debug/debug bash
        $ bin/instance fg

5. Now, via Rancher UI:

    * Within `www-debug` stack find `exposed` port for `8080` and **click** on it.
