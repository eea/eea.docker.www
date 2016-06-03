#!/bin/bash

USR=`cat /etc/passwd | grep zope-www`

if [ -z "$USR" ]; then
  echo "Adding zope-www user..."
  useradd -u 500 zope-www
  usermod -a -G docker zope-www
  ln -s /usr/local/bin/docker-compose /bin/docker-compose
  echo "Done"
fi

FSTAB=`cat /etc/fstab | grep /var/blobstorage`
if [ -z "$FSTAB" ]; then
  echo "Mounting /var/zodb and /var/blobstorage..."
  mkdir -p /var/zodb
  mkdir -p /var/blobstorage
  echo "10.142.71.182:/mnt/vdb1/zodbfilestorage      /var/zodb        nfs     defaults,ro     0 0" >> /etc/fstab
  echo "10.142.71.182:/mnt/vdb1/sharedblobstorage    /var/blobstorage      nfs     nfsvers=3,rsize=32768,wsize=32768,noatime,nodiratime        0 0" >> /etc/fstab
  echo "Done"
  mount -a
fi

if [ ! -f $(pwd)/backup/datafs.gz ]; then
  echo "Copy database zip datafs.gz from /var/zodb/ to $(pwd)/backup/ ..."
  rsync --progress -a /var/zodb/pg_dump/*.gz $(pwd)/backup/
  echo "Done"
fi

echo "Fixing permissions..."
chown -R zope-www:docker .
echo "Done"

if [ ! -d $(pwd)/src/eea.devel ]; then
  echo "Updating source code..."
  su zope-www -c "docker-compose -f source-code.yml up"
fi
