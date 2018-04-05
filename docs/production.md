# Docker orchestration for EEA main portal (www-prod)

Docker orchestration for EEA main portal services

## Pre-requirements

* Dedicated Rancher Environment (recommended)
* SSH access on Docker hosts

### Register hosts within Rancher via Rancher UI

* Register dedicated `backend` hosts with label: `www=yes`, `backend=yes` (Plone)
* Make sure NFS resources are properly mounted on hosts

        $ cat /etc/fstab
        $ ls /var/sharedblobstorage

* Make sure NFSv4 support is properly configured on these hosts. See [ticket #80428](https://taskman.eionet.europa.eu/issues/80428#note-5)

### Setup infrastructure

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA WWW - Volumes
    * As on production we don't use `rancher-nfs` driver, make sure you mount NFS resources from host by setting `NFS_VOLUMES_ROOT=/var/sharedblobstorage/`
  * EEA WWW - Sync
    * As on production we don't use `rancher-nfs` driver, make sure you mount NFS resources from host by setting `NFS_VOLUMES_ROOT=/var/sharedblobstorage/`
    * Leave empty `SSH Public Key (PostgreSQL)`
    * Set `SSH Public Key (rsync-client)` to `DISABLED`
    * Make sure that this `rsync-client` can connect to `rsync-server` on **www-prod-replica** tenant. (blobs and static-resources sync)

### Setup database

> **Note:** Not managed via Rancher. See **EEA wiki: How to update the EEA website on HA cluster**

### Start EEA Application front-end stack (Apache, Varnish, HAProxy, Memcached)

> **Note:** Not managed via Rancher. See **EEA wiki: How to update the EEA website on HA cluster**

## Install

### Rancher

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - WWW (Plone)

## Release and upgrade `www-plone`

### Release `www-plone` stack

1. **Add new catalog version** within [eea.rancher.catalog](https://github.com/eea/eea.rancher.catalog/tree/master/templates/www-plone)

   * Prepare next release, e.g.: `17.9`:

        ```
        $ git clone git@github.com:eea/eea.rancher.catalog.git
        $ cd eea.rancher.catalog/templates/www-plone

        $ cp -r 59 60
        $ git add 60
        $ git commit -m "Prepare release 17.9"
        ```

   * Release new version, e.g:. `17.9`:

        ```
        $ vim config.yml
        version: "17.9"

        $ vim 60/rancher-compose.yml
        ...
        version: "17.9"
        ...
        uuid: www-plone-60
        ...

        $ vim 60/docker-compose.yml
        ...
        - image: eeacms/www:17.9
        ...

        $ git add .
        $ git commit -m "Release 17.9"
        $ git push
        ```

   * See [Rancher docs](https://docs.rancher.com/rancher/v1.2/en/catalog/private-catalog/#rancher-catalog-templates) for more details.

### Upgrade `www-plone` stack

1. **Upgrade Rancher** deployment

   * Click the available upgrade button

   * Confirm the upgrade

   * Or roll-back if something goes wrong and abort the upgrade procedure

### Release and upgrade `www-frontend` stack

### Release `www-frontend` stack

1. **Add new catalog version** within [eea.rancher.catalog](https://github.com/eea/eea.rancher.catalog/tree/master/templates/www-frontend)

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

        $ vim 1/docker-compose.yml
        ...
        - image: eeacms/apache-eea-www:1.1
        ...

        $ git add .
        $ git commit -m "Release 1.1"
        $ git push
        ```
### Upgrade `www-frontend` stack

2. **Note:** Not managed via Rancher, yet. See **EEA wiki: How to update the EEA website on HA cluster**

## Debug

### Rancher

1. Start Plone instance in `debug` mode

        $ rancher exec -it www-plone/debug-instance bash
        $ bin/instance fg

2. Now, via Rancher UI:

    * Within `www-plone/debug-instance` stack find `exposed` port for `8080` and **click** on it.
