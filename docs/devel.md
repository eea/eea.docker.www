# Docker orchestration for EEA main portal (Devel 2: A-Team)

Docker orchestration for EEA main portal services

### Register hosts within Rancher and label them

* Add labels: `www=yes`, `backend=yes`, `plone=yes`,
* Add label on one host: `sync=yes`

### Setup infrastructure

> **Note:** See **EEA SVN** for `answers.txt` files

* From **Rancher Catalog > EEA** deploy:
  * EEA WWW - Volumes
  * EEA WWW - Sync
    * Get `SSH Public Key (rsync-client)` from `www-prod-replica > www-sync > rsync-client > www-sync-rsync-client-1 > Console`
    * Make sure that `rsync-client` on **www-prod-replica** can connect to this `rsync-server`.
