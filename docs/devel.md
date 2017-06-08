# Docker orchestration for EEA main portal (Devel 2: A-Team)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher CLI](https://docs.rancher.com/rancher/v1.2/en/cli/)

## Installation

On your laptop

    $ git clone https://github.com/eea/eea.docker.www.git
    $ cd eea.docker.www

### Add deployment infrastructure within your cloud provider

    $ cd templates/infrastructure

Add required info within `.cloudaccess` and `.secret` needed by [eeacms/os-docker-vm](https://github.com/eea/eea.docker.openstack.host#usage)

    $ vim .cloudaccess
    $ vim .secret


The `base-flavors.yml` contains the basic flavors specifications for the infrastructure. Make sure that you are using the correct tag for eeacms/os-docker-vm.

The `docker-compose.yml` extends the base-flavors.yml to create specific number of VMs. Adjust the `INSTANCE_NAME` in order to give the unique names and according to your naming conventions.

To create the VMs run the following command and note the output:

    $ docker-compose up fileserver1 db1 frontend

After around 5 min you should have all the VMs created on the specified cloud provider tenant and region.

### Register above hosts within Rancher

* Register dedicated `db` hosts with labels: `www=yes`, `db=yes`, `db-master=yes` (PostgreSQL)
* Register dedicated `frontend` hosts with label: `www=yes`, `frontend=yes` (Varnish, Apache)
* Add Public IP to one `frontend` and label it within Rancher UI with `sync=yes`, `db=yes`, `db-upstream=yes` (Sync)

### Setup NFS server to be used with Rancher-NFS (shared blobs and static resources)

    $ ssh <fileserver-ip>
    $ docker run --rm -v nfs:/data alpine touch /data/test
    $ echo "/var/lib/docker/volumes/nfs/_data 10.201.1.1/24(rw,insecure,no_root_squash) 10.42.0.0/16(rw,insecure,no_root_squash)" >> /etc/exports
    $ systemctl enable rpcbind nfs-server
    $ systemctl restart rpcbind nfs-server

### Access rights

To enable Rancher CLI to launch services in a Rancher instance, you’ll need to configure it
See related [Rancher documentation](http://docs.rancher.com/rancher/v1.3/en/api/v2-beta/access-control/)
on how to obtain your Rancher API Keys. Thus:

1. Via Rancher UI:

    * Go to **API Tab** add an **Account API Key**

2. On your laptop configure Rancher CLI:

        $ rancher --config ~/.rancher/rancher.dev.json config
        $ cp ~/.rancher/rancher.dev.json ~/.rancher/cli.json

3. Make sure that you're deploying within the right environment:

        $ rancher config -p

### Setup infrastructure

**Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > Library** deploy:
  * Rancher NFS
* From **Rancher Catalog > EEA** deploy:
  * EEA WWW - Volumes
  * EEA WWW - Sync
    * Get `SSH Public Key (rsync-client)` from `www-prod-replica > www-sync > rsync-client > www-sync-rsync-client-1 > Console`
    * Leave empty `SSH Public Key (PostgreSQL)`
    * Make sure that `rsync-client` on **www-prod-replica** can connect to this `rsync-server`.

### Setup database

**Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - PostgreSQL
    * Name: `www-postgres`
