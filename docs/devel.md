# Docker orchestration for EEA main portal (Devel 2: A-Team)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher Compose](http://docs.rancher.com/rancher/rancher-compose/)

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

    $ docker-compose up fileserver1 db1 frontend

After around 5 min you should have all the VMs created on the specified cloud provider tenant and region.

### Register above hosts within Rancher

* Register dedicated `fileserver` hosts with labels `nfs-server=yes` (NFS Server)
* Register dedicated `db` hosts with labels: `www=yes`, `db=yes` (PostgreSQL)
* Register dedicated `frontend` hosts with label: `www=yes`, `frontend=yes` (Varnish, Apache)
* Add Public IP to one `frontend` and label it within Rancher UI with `sync=yes` and `public=yes` (Sync, Load Balancer)

### Setup NFS server to be used with ConvoyNFS (shared blobs and static resources)

    $ ssh <fileserver-ip>
    $ docker run --rm -v nfs:/data alpine touch /data/test
    $ echo "/var/lib/docker/volumes/nfs/_data 10.201.1.1/24(rw,insecure,no_root_squash) 10.42.0.0/16(rw,insecure,no_root_squash)" >> /etc/exports
    $ systemctl enable rpcbind nfs-server
    $ systemctl restart rpcbind nfs-server

### Access rights

To enable Rancher Compose to launch services in a Rancher instance, you’ll need to set environment variables or pass
these variables as an option in the Rancher Compose command.
See related [Rancher documentation](https://docs.rancher.com/rancher/v1.0/en/configuration/api-keys/#adding-environment-api-keys)
on how to obtain your Rancher API Keys.

Thus on your laptop:

* Add Rancher specific environment variables (API URL, access and secret key):

      $ cd deploy
      $ cp .secret.example .secret.devel
      $ vim .secret.devel

* And make them available:

      $ source .secret.devel

* Make sure you're deploying to the right Rancher Environment:

      $ env | grep RANCHER

### Start Convoy NFS driver

Back to your laptop

    $ cd deploy/www-nfs
    $ rancher-compose -e ../devel.env pull
    $ rancher-compose -e ../devel.env up -d

### Start SYNC stack (sync blobs and static resources from staging/to testing)

    $ cd deploy/www-sync
    $ rancher-compose -e ../devel.env pull
    $ rancher-compose -e ../devel.env up -d

Make sure that `rsync-client` on staging can connect to this `rsync-server`.


### Start DB stack

    $ cd deploy/www-db
    $ rancher-compose -e ../devel.env -f devel.yml pull
    $ rancher-compose -e ../devel.env -f devel.yml up -d
