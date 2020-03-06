#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for blocknetd"
  set -- blocknetd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "/opt/bitcoinhot/blocknetd" ]; then
  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "/opt/bitcoinhot/blocknetd" ] || [ "$1" = "/opt/bitcoinhot/blocknet-cli" ] || [ "$1" = "/opt/bitcoinhot/blocknet-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
