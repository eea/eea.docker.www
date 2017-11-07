# Docker orchestration for EEA main portal (Devel 2: A-Team)

Docker orchestration for EEA main portal services

### Register hosts within Rancher and label them

* Add labels: `www=yes`, `db=yes`

### Setup infrastructure

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > Library** deploy:
  * Rancher NFS
* From **Rancher Catalog > EEA** deploy:
  * EEA WWW - Volumes
  * EEA WWW - Sync
    * Get `SSH Public Key (rsync-client)` from `www-prod > www-sync > rsync-client > www-sync-rsync-client-1 > Console`
    * Get `SSH Public Key (PostgreSQL)` from `db-pg-<MASTER> > postgres`
    * Make sure that `rsync-client` on **www-prod** can connect to this `rsync-server`.
    * Make sure that **Production PostgreSQL** can connect to this `rsync-server`. (PostgreSQL upstream replica)

### Setup database (upstream replica)

> **Note:** See **EEA SVN** for `answers.txt` files

* Sync database

        $ ssh <postgresql master on production>
        $ cd /var/lib/pgsql/9.4/data
        $ vim cph-backup.sh
        $ ./cph-backup.sh

* From **Rancher Catalog > EEA** deploy **EEA - PostgreSQL** stack
  * Name: `www-postgres-upstream-replica`

