# Docker orchestration for EEA main portal (www-prod-replica)

Docker orchestration for EEA main portal services

## Pre-requirements

* Dedicated Rancher Environment (recommended)

### Register hosts within Rancher via Rancher UI

* Register dedicated `db` hosts with labels: `db=yes` (PostgreSQL)
* Register dedicated `backend` hosts with label: `backend=yes` (Plone)
* Register dedicated `frontend` hosts with label: `frontend=yes` (Varnish, Apache, HAProxy)

### Setup infrastructure

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > Library** deploy:
  * Rancher NFS
* From **Rancher Catalog > EEA** deploy:
  * EEA WWW - Volumes
    * DB Volume Driver: `external`
  * EEA WWW - Sync
    * Get `SSH Public Key (rsync-client)` from `WWW AWS > www-sync > rsync-client > www-sync-rsync-client-1 > Console`
    * `SSH Public Key (PostgreSQL)` DISABLED
    * Make sure that `rsync-client` on **www-aws** can connect to this `rsync-server`.
    * Make sure that `rsync-client` can connect to `rsync-server` from devel environment

### Setup database backend

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - PostgreSQL
    * Name: `www-postgres`

### Setup Plone backend

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - WWW (Plone)

### Setup Frontend

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - Frontend
  * EEA - Load Balancer

## Upgrade

*  Within Rancher UI press the available upgrade buttons

* Confirm the upgrade

* Or roll-back if something goes wrong and abort the upgrade procedure

## Debug

1. Start Plone instance in `debug` mode

        $ rancher exec -it www-plone/debug-instance bash
        $ bin/instance fg

2. Now, via Rancher UI:

    * Within `www-plone/debug-instance` stack find `exposed` port for `8080` and **click** on it.
