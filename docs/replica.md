# Docker orchestration for EEA main portal (www-replica-prod)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher CLI](https://docs.rancher.com/rancher/v1.2/en/cli/)
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

### Register above hosts within Rancher via Rancher UI

* Register dedicated `db` hosts with labels: `www=yes`, `db=yes` and `db-master=yes`/ `db-replica=yes` (PostgreSQL)
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

To enable Rancher CLI to launch services in a Rancher instance, you’ll need to configure it
See related [Rancher documentation](http://docs.rancher.com/rancher/v1.3/en/api/v2-beta/access-control/)
on how to obtain your Rancher API Keys. Thus:

1. Via Rancher UI:

    * Go to **API Tab** add an **Account API Key**

2. On your laptop configure Rancher CLI:

        $ rancher --config ~/.rancher/rancher.replica.json config
        $ cp ~/.rancher/rancher.replica.json ~/.rancher/cli.json

3. Make sure that you're deploying within the right environment:

        $ rancher config -p

### Setup NFS volumes support

* From `Rancher Catalog > Library` deploy `Rancher NFS` stack:
  * NFS_SERVER: `10.128.1.27`
  * MOUNT_DIR: `/var/lib/docker/volumes/nfs/_data`
  * MOUNT_OPTS: `noatime`

### Create NFS/DB volumes

        $ cd deploy/www-volumes
        $ rancher up -d -e ../replica.env

### Start SYNC stack (sync blobs and static resources from production/to testing)

        $ cd deploy/www-sync
        $ rancher up -d -e ../replica.env

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
        $ rancher up -d -e ../replica.env -f replica.yml

### Start EEA Application stack (plone backends, memcache, varnish, apache)

        $ cd deploy/www-eea
        $ rancher up -d -e ../replica.env

### Add Load-Balancer (optional if not done already by other stack)

Within Rancher UI add Rancher Load Balancer for `www-eea/apache` containers
scheduled on hosts with label `public=yes`

## Upgrade

### Upgrade Backend stack (plone instances, async workers)

1. On your laptop

        $ git clone https://github.com/eea/eea.docker.www.git
        $ cd eea.docker.www/deploy

2. Configure Rancher CLI:

        $ rancher --config ~/.rancher/rancher.replica.json config
        $ cp ~/.rancher/rancher.replica.json ~/.rancher/cli.json

3. Now **make sure that you're deploying within the right environment**:

        $ rancher config -p

4. Update `KGS_VERSION` within `deploy/replica.env`

        $ git pull
        $ vim replica.env

5. Upgrade:

        $ cd www-eea
        $ rancher up -d -e ../replica.env --upgrade --batch-size 1

6. If the upgrade went well, finish the upgrade with:

        $ rancher up -d -e ../replica.env --confirm-upgrade
        $ git add replica.env
        $ git commit
        $ git push

### Roll-back upgrade

* In case something went wrong, roll-back:

        $ rancher up -d -e ../replica.env --rollback

## Debug

1. On your laptop:

        $ git clone https://github.com/eea/eea.docker.www.git
        $ cd eea.docker.www

2. Make sure that you're deploying within the right environment:

        $ rancher config

3. Start debug stack:

        $ cd deploy/www-debug
        $ rancher up -d -e ../replica.env

4. Start Plone instance in `debug` mode

        $ rancher exec -it www-debug/debug bash
        $ bin/instance fg

5. Now, via Rancher UI:
    * Within `www-debug` stack find `exposed` port for `8080` and **click** on it.
