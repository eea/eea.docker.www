# Docker orchestration for EEA main portal (www-prod)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher CLI](https://docs.rancher.com/rancher/v1.4/en/cli/)
* Dedicated Rancher Environment (recommended)

## Installation

On your laptop:

        $ git clone https://github.com/eea/eea.docker.www.git
        $ cd eea.docker.www

### Register hosts within Rancher via Rancher UI

* Register dedicated `backend` hosts with label: `www=yes`, `backend=yes` (Plone)
* Register dedicated `frontend` hosts with label: `www=yes`, `frontend=yes` (Varnish, Apache, Memcached, Postfix)
* Add Public IP to one `frontend` and label it within Rancher UI with `sync=yes` and `public=yes` (Sync, Load Balancer)
* **Make sure NFSv4 support is properly configured on these hosts. See** [ticket #80428](https://taskman.eionet.europa.eu/issues/80428#note-5)

### Setup NFS server to be used with Rancher-NFS (shared blobs and static resources)

        $ ssh <fileserver-ip>
        $ docker run --rm -v nfs:/data alpine touch /data/test
        $ echo "/var/lib/docker/volumes/nfs/_data 10.128.0.0/24(rw,insecure,no_root_squash) 10.42.0.0/16(rw,insecure,no_root_squash)" >> /etc/exports
        $ systemctl enable rpcbind nfs-server
        $ systemctl restart rpcbind nfs-server

### CLI access rights

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


### Setup infrastrucutre

**Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > Library** deploy:
  * Rancher NFS
* From **Rancher Catalog > EEA** deploy:
  * EEA WWW - Volumes
  * EEA WWW - Sync
    * Leave empty `SSH Public Key (PostgreSQL)`
    * Set `SSH Public Key (rsync-client)` to `DISABLED`
    * Make sure that this `rsync-client` can connect to `rsync-server` on **www-prod-replica** tenant. (blobs and static-resources sync)

### Setup database

**Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - External
    * Name: `www-postgres`

### Start EEA Application front-end stack (Apache, Varnish, HAProxy, Memcached)

**Note:** See **EEA SVN** for `answers.txt` files

* Manually deploy Rancher Catalog entry with docker-compose

    $ ssh user@frontend-1
    $ cd /var/local/deploy/
    $ git clone https://github.com/eea/eea.rancher.catalog.git
    $ ln -s eea.rancher.catalog/templates/www-frontend www-frontend
    $ cd www-frontend

* Setup environment

    $ cp answers.txt .env
    $ vim .env

* Create required volumes

    $ docker volume create --name=www-static-resources

* Start

    $ docker-compose -f 0/docker-compose.yml up -d


## Upgrade

### Upgrade `www-frontend` stack

1. Add new catalog version within [eea.rancher.catalog](https://github.com/eea/eea.rancher.catalog/tree/master/templates/www-frontend)

   * Prepare next release, e.g.: `17.9`:

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

   * See [Rancher docs](https://docs.rancher.com/rancher/v1.2/en/catalog/private-catalog/#rancher-catalog-templates) for more details.

2. SSH on one frontend and upgrade git repository

        $ ssh user@fronend-1
        $ cd /var/local/deploy/www-frontend
        $ git pull

3. Find running version:

        $ docker ps
        0_apache_1 ...
        ...

4. The number before container name indicates the current running version, in our case `0`, stop it and start the new one:

        $ docker-compose -f 1/docker-compose.yml pull

        $ docker-compose -f 0/docker-compose.yml stop

        $ docker-compose -f 1/docker-compose.yml up -d

5. If something went wrong, roll-back:

        $ docker-compose -f 1/docker-compose.yml stop

        $ docker-compose -f 0/docker-compose.yml start

6. If everything is ok, confirm upgrade:

        $ docker-compose -f 0/docker-compose.yml rm

7. Move to the next front-end and repeat steps `2-6`
