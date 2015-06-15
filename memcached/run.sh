#!/bin/bash
set -x

PARAMS=""

# TCP port number to listen on (default: 11211)
if [ ! -z "$MEMCACHED_PORT" ]; then
  PARAMS="$PARAMS -p $MEMCACHED_PORT"
fi

# Max memory to use for items in megabytes (default: 64 MB)
if [ ! -z "$MEMCACHED_MEMORY" ]; then
  PARAMS="$PARAMS -m $MEMCACHED_MEMORY"
fi

# max simultaneous connections (default: 1024)
if [ ! -z "$MEMCACHED_CONNECTIONS" ]; then
  PARAMS="$PARAMS -c $MEMCACHED_CONNECTIONS"
fi

# number of threads to use (default: 4)
if [ ! -z "$MEMCACHED_THREADS" ]; then
  PARAMS="$PARAMS -t $MEMCACHED_THREADS"
fi

/usr/local/bin/memcached $PARAMS
