#!/bin/bash
set -e

if [ -f .installed ]; then
  echo "====================================================================="
  echo "infrastructure already added. Please remove .installed file to re-run"
  echo "====================================================================="
  exit 0
fi

touch .installed

# XXX See https://taskman.eionet.europa.eu/issues/71950
#docker-compose -f infrastructure.yml scale fileserver=3 db=2 backend=4 frontend=2

PREFIX="dev-mil"
SUFFIX=10

echo "====================================================================="
echo "Adding fileserver VMs"
echo "====================================================================="

for i in {10..12}; do
  docker run --rm \
             --env-file=.secret \
             --env-file=.cloudaccess \
             -e INSTANCE_NAME=$PREFIX-$i \
             -e INSTANCE_DOCKER_VOLUME_SIZE=256 \
             -e INSTANCE_DOCKER_VOLUME_TYPE=top \
             -e INSTANCE_FLAVOR=e2standard.x4 \
          eeacms/os-docker-vm
done

echo "====================================================================="
echo "Adding DB VMs"
echo "====================================================================="

for i in {13..14}; do
  docker run --rm \
             --env-file=.secret \
             --env-file=.cloudaccess \
             -e INSTANCE_NAME=$PREFIX-$i \
             -e INSTANCE_DOCKER_VOLUME_SIZE=64 \
             -e INSTANCE_DOCKER_VOLUME_TYPE=top \
          eeacms/os-docker-vm
done

echo "====================================================================="
echo "Adding Plone Backend VMs"
echo "====================================================================="

for i in {15..18}; do
  docker run --rm \
             --env-file=.secret \
             --env-file=.cloudaccess \
             -e INSTANCE_NAME=$PREFIX-$i \
             -e INSTANCE_FLAVOR=e2standard.x4 \
          eeacms/os-docker-vm
done

echo "====================================================================="
echo "Adding Frontend VMs"
echo "====================================================================="

for i in {19..20}; do
  docker run --rm \
             --env-file=.secret \
             --env-file=.cloudaccess \
             -e INSTANCE_NAME=$PREFIX-$i \
             -e INSTANCE_FLAVOR=e2standard.x4 \
          eeacms/os-docker-vm
done
