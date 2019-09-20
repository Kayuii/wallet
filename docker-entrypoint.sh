#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for blocknetdxd"
  set -- blocknetdxd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "blocknetdxd" ]; then
  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "blocknetdxd" ] || [ "$1" = "blocknetdx-cli" ] || [ "$1" = "blocknetdx-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
