# Docker orchestration for EEA main portal (www-prod)

Docker orchestration for EEA main portal services

## Pre-requirements

* [Rancher CLI](https://docs.rancher.com/rancher/v1.5/en/cli/)
* Dedicated Rancher Environment (recommended)

## Installation

### CLI access rights

To enable Rancher CLI to launch services in a Rancher instance, you’ll need to configure it
See related [Rancher documentation](http://docs.rancher.com/rancher/v1.5/en/api/v2-beta/access-control/)
on how to obtain your Rancher API Keys. Thus:

1. Via Rancher UI:

    * Go to **API Tab** add an **Account API Key**

2. On your laptop configure Rancher CLI:

        $ rancher --config

### Register hosts within Rancher via Rancher UI

* Register dedicated `backend` hosts with label: `www=yes`, `backend=yes` (Plone)
* Register dedicated `frontend` hosts with label: `www=yes`, `frontend=yes` (Varnish, Apache, Memcached, HAProxy)

* **Make sure NFSv4 support is properly configured on these hosts. See** [ticket #80428](https://taskman.eionet.europa.eu/issues/80428#note-5)

### Setup infrastructure

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > Library** deploy:
  * Rancher NFS
* From **Rancher Catalog > EEA** deploy:
  * EEA WWW - Volumes
  * EEA WWW - Sync
    * Leave empty `SSH Public Key (PostgreSQL)`
    * Set `SSH Public Key (rsync-client)` to `DISABLED`
    * Make sure that this `rsync-client` can connect to `rsync-server` on **www-prod-replica** tenant. (blobs and static-resources sync)

### Setup database

> **Note:** Not managed via Rancher. See **EEA wiki: How to update the EEA website on HA cluster**

### Start EEA Application front-end stack (Apache, Varnish, HAProxy, Memcached)

> **Note:** Not managed via Rancher. See **EEA wiki: How to update the EEA website on HA cluster**

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

See [Rancher docs](https://docs.rancher.com/rancher/v1.2/en/catalog/private-catalog/#rancher-catalog-templates) for more details.

## Debug

1. Start Plone instance in `debug` mode

        $ rancher exec -it www-plone/debug-instance bash
        $ bin/instance fg

2. Now, via Rancher UI:

    * Within `www-plone/debug-instance` stack find `exposed` port for `8080` and **click** on it.
