#!/bin/bash
set -e

if [ -f .installed ]; then
  echo "============================================================================"
  echo "ERROR: Infrastructure already added. Please remove .installed file to re-run"
  echo "============================================================================"
  exit 1
fi

touch .installed

## XXX See https://taskman.eionet.europa.eu/issues/71950.
## When ticket above is closed uncomment the line bellow and remove everything after
#docker-compose -f infrastructure.yml scale fileserver=3 db=2 backend=4 frontend=2

if [ -z "$PREFIX" ]; then
  echo "====================================================================="
  echo "WARNING: Host name prefix not provided. Using PREFIX=dev-mil"
  echo "====================================================================="
  PREFIX="dev-mil"
fi

if [ -z "$SUFFIX" ]; then
  echo "====================================================================="
  echo "WARNING: Next host name available not provided. Using SUFFIX=50"
  echo "====================================================================="
  SUFFIX=50
fi

echo "====================================================================="
echo "Adding fileserver VMs"
echo "====================================================================="

# for i in {10..12}; do
for (( i=$SUFFIX; i<=($SUFFIX+2); i++ )); do
  echo "Adding host $PREFIX-$i"
  docker run --rm \
             --env-file=.secret \
             --env-file=.cloudaccess \
             -e INSTANCE_NAME=$PREFIX-$i \
             -e INSTANCE_DOCKER_VOLUME_SIZE=384 \
             -e INSTANCE_DOCKER_VOLUME_TYPE=top \
          eeacms/os-docker-vm
done

echo "====================================================================="
echo "Adding DB VMs"
echo "====================================================================="

# for i in {13..14}; do
for (( i=$SUFFIX+3; i<=($SUFFIX+4); i++ )); do
  echo "Adding host $PREFIX-$i"
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

# for i in {15..18}; do
for (( i=$SUFFIX+5; i<=($SUFFIX+8); i++ )); do
  echo "Adding host $PREFIX-$i"
  docker run --rm \
             --env-file=.secret \
             --env-file=.cloudaccess \
             -e INSTANCE_NAME=$PREFIX-$i \
          eeacms/os-docker-vm
done

echo "====================================================================="
echo "Adding Frontend VMs"
echo "====================================================================="

# for i in {19..20}; do
for (( i=$SUFFIX+9; i<=($SUFFIX+10); i++ )); do
  echo "Adding host $PREFIX-$i"
  docker run --rm \
             --env-file=.secret \
             --env-file=.cloudaccess \
             -e INSTANCE_NAME=$PREFIX-$i \
          eeacms/os-docker-vm
done
