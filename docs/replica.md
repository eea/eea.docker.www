# Docker orchestration for EEA main portal (www-prod-replica)

Docker orchestration for EEA main portal services


### Register hosts within Rancher via Rancher UI

* Register dedicated `db` hosts with labels: `www=yes`, `db=yes` and `db-upstream=yes` / `db-master=yes`/ `db-replica=yes` (PostgreSQL)
* Register dedicated `backend` hosts with label: `www=yes`, `backend=yes` (Plone)
* Register dedicated `frontend` hosts with label: `www=yes`, `frontend=yes` (Varnish, Apache)

### Setup infrastructure

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > Library** deploy:
  * Rancher NFS
* From **Rancher Catalog > EEA** deploy:
  * EEA WWW - Volumes
    * DB Volume Driver: `rancher-ebs`
  * EEA WWW - Sync
    * Get `SSH Public Key (rsync-client)` from `www-prod > www-sync > rsync-client > www-sync-rsync-client-1 > Console`
    * Get `SSH Public Key (PostgreSQL)` from `db-pg-c > postgres`
    * Make sure that `rsync-client` on **www-prod** can connect to this `rsync-server`.
    * Make sure that **Production PostgreSQL** can connect to this `rsync-server`. (PostgreSQL upstream replica)
    * Make sure that `rsync-client` can connect to `rsync-server` from devel environment

### Setup database (upstream replica)

> **Note:** See **EEA SVN** for `answers.txt` files

* Update db-pg-archive.sh script `REPLICA_SERVER`

        $ ssh <postgresql master on production>
        $ cd /var/lib/pgsql/9.6/
        $ vim data/db-pg-archive.sh

* Sync database

        $ vim data/amazon-backup.sh
        $ ./data/amazon-backup.sh > amazon-sync.log 2>&1 &
        $ tail -f amazon-sync.log

* From **Rancher Catalog > EEA** deploy **EEA - PostgreSQL** stack
  * Name: `www-postgres-amazon-replica`

### Setup database

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - PostgreSQL (Cluster)
    * Name: `www-postgres-cluster`

### Start EEA Application Plone stack

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - WWW (Plone)

### Start EEA Application front-end stack (Apache, Varnish, HAProxy, Memcached)

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA - Frontend

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

   * See [Rancher docs](http://rancher.com/docs/rancher/latest/en/catalog/private-catalog/) for more details.

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

        $ vim 1/docker-compose.yml
        ...
        - image: eeacms/apache-eea-www:1.1
        ...

        $ git add .
        $ git commit -m "Release 1.1"
        $ git push
        ```
   * See [Rancher docs](http://rancher.com/docs/rancher/latest/en/catalog/private-catalog/) for more details.

2. Within Rancher UI press the available upgrade button

## Debug

1. Start Plone instance in `debug` mode

        $ rancher exec -it www-plone/debug-instance bash
        $ bin/instance fg

2. Now, via Rancher UI:

    * Within `www-plone/debug-instance` stack find `exposed` port for `8080` and **click** on it.
