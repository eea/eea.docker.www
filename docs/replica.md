# Docker orchestration for EEA main portal (www-prod-replica)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher CLI](https://docs.rancher.com/rancher/v1.5/en/cli/)
* Dedicated Rancher Environment (recommended)

## Installation

### Add deployment infrastructure within your cloud provider

    $ cd templates/infrastructure

Add required info within `.cloudaccess` and `.secret` needed by [eeacms/os-docker-vm](https://github.com/eea/eea.docker.openstack.host#usage)

    $ vim .cloudaccess
    $ vim .secret

The `base-flavors.yml` contains the basic flavors specifications for the infrastructure. Make sure that you are using the correct tag for eeacms/os-docker-vm.

The `docker-compose.yml` extends the base-flavors.yml to create specific number of VMs. Adjust the `INSTANCE_NAME` in order to give the unique names and according to your naming conventions.

To create the VMs run the following command and note the output:

    $ docker-compose up

After around 5 min you should have all the VMs created on the specified cloud provider tenant and region.

### Register above hosts within Rancher via Rancher UI

* Register dedicated `db` hosts with labels: `www=yes`, `db=yes` and `db-upstream=yes` / `db-master=yes`/ `db-replica=yes` (PostgreSQL)
* Register dedicated `backend` hosts with label: `www=yes`, `backend=yes` (Plone)
* Register dedicated `frontend` hosts with label: `www=yes`, `frontend=yes` (Varnish, Apache)
* Add Public IP to one `frontend` and label it within Rancher UI with `sync=yes` and `public=yes` (Sync, Load Balancer)

### Setup NFS server to be used with Rancher-NFS (shared blobs and static resources)

    $ ssh <fileserver-ip>
    $ docker run --rm -v nfs:/data alpine touch /data/test
    $ echo "/var/lib/docker/volumes/nfs/_data 10.128.0.0/24(rw,insecure,no_root_squash) 10.42.0.0/16(rw,insecure,no_root_squash)" >> /etc/exports
    $ systemctl enable rpcbind nfs-server
    $ systemctl restart rpcbind nfs-server

### CLI access rights

To enable Rancher CLI to launch services in a Rancher instance, you’ll need to configure it
See related [Rancher documentation](http://docs.rancher.com/rancher/v1.5/en/api/v2-beta/access-control/)
on how to obtain your Rancher API Keys. Thus:

1. Via Rancher UI:

    * Go to **API Tab** add an **Account API Key**

2. On your laptop configure Rancher CLI:

        $ rancher --config

### Setup infrastructure

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > Library** deploy:
  * Rancher NFS
* From **Rancher Catalog > EEA** deploy:
  * EEA WWW - Volumes
  * EEA WWW - Sync
    * Get `SSH Public Key (rsync-client)` from `www-prod > www-sync > rsync-client > www-sync-rsync-client-1 > Console`
    * Get `SSH Public Key (PostgreSQL)` from `db-pg-c > postgres`
    * Make sure that `rsync-client` on **www-prod** can connect to this `rsync-server`.
    * Make sure that **Production PostgreSQL** can connect to this `rsync-server`. (PostgreSQL upstream replica)
    * Make sure that this `rsync-client` can connect to `rsync-server` on **Devel tenant**. (DB pg_dump, blobs and static-resources sync)

### Setup database (upstream replica)

> **Note:** See **EEA SVN** for `answers.txt` files

* Sync database

        $ ssh <postgresql master on production>
        $ cd /var/lib/pgsql/9.4/data
        $ vim ecs-backup.sh
        $ ./ecs-backup.sh

* From **Rancher Catalog > EEA** deploy **EEA - PostgreSQL** stack
  * Name: `www-postgres-upstream-replica`

### Setup database

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - PostgreSQL (Cluster)
    * Name: `www-postgres`

### Start EEA Application front-end stack (Apache, Varnish, HAProxy, Memcached)

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - Frontend

### Start EEA Application Plone stack

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - WWW (Plone)


## Upgrade

### Upgrade `www-plone` stack

1. Add new catalog version within [eea.rancher.catalog](https://github.com/eea/eea.rancher.catalog/tree/master/templates/www-plone)

   * Prepare next release, e.g.: `17.9`:

        ```
        $ git clone git@github.com:eea/eea.rancher.catalog.git
        $ cd eea.rancher.catalog/templates/www-plone

        $ cp -r 33 34
        $ git add 34
        $ git commit -m "Prepare release 17.9"
        ```

   * Release new version, e.g:. `17.9`:

        ```
        $ vim config.yml
        version: "17.9"

        $ vim 34/rancher-compose.yml
        ...
        version: "17.9"
        ...
        uuid: www-plone-34
        ...

        $ vim 34/docker-compose.yml
        ...
        - image: eeacms/www:17.9
        ...

        $ git add .
        $ git commit -m "Release 17.9"
        $ git push
        ```

   * See [Rancher docs](https://docs.rancher.com/rancher/v1.2/en/catalog/private-catalog/#rancher-catalog-templates) for more details.

2. Within Rancher UI press the available upgrade button

### Upgrade `www-frontend` stack

1. Add new catalog version within [eea.rancher.catalog](https://github.com/eea/eea.rancher.catalog/tree/master/templates/www-frontend)

   * Prepare next release, e.g.: `1.1`:

        ```
        $ git clone git@github.com:eea/eea.rancher.catalog.git
        $ cd eea.rancher.catalog/templates/www-frontend

        $ cp -r 0 1
        $ git add 1
        $ git commit -m "Prepare release 1.1"
        ```

   * Release new version, e.g:. `1.1`:

        ```
        $ vim config.yml
        version: "1.1"

        $ vim 1/rancher-compose.yml
        ...
        version: "1.1"
        ...
        uuid: www-frontend-1
        ...

        $ git add .
        $ git commit -m "Release 1.1"
        $ git push
        ```
2. Within Rancher UI press the available upgrade button

## Debug

1. Start Plone instance in `debug` mode

        $ rancher exec -it www-plone/debug-instance bash
        $ bin/instance fg

2. Now, via Rancher UI:

    * Within `www-plone/debug-instance` stack find `exposed` port for `8080` and **click** on it.
