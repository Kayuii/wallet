#!/bin/bash
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for siad"

  set -- siad "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "siad" ]; then
  mkdir -p "$BITCOIN_DATA"

  chown -R bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.sia
  chown -h bitcoin:bitcoin /home/bitcoin/.sia

  echo "$0: setting data directory to $BITCOIN_DATA"

  # socat tcp-listen:9980,reuseaddr,fork tcp:localhost:8000 & siad   --modules \"$SIA_MODULES\"   --sia-directory \"$SIA_DATA_DIR\"   --api-addr \"localhost:8000\"   --authenticate-api=false
  set -- "$@" --modules="gctwhr" --sia-directory="$BITCOIN_DATA" --authenticate-api=false --api-addr=localhost:8000
fi

if [ "$1" = "siad" ] || [ "$1" = "siac" ] ; then
  echo "run : socat tcp-listen:9980,reuseaddr,fork tcp:localhost:8000 & $@ "
  exec gosu bitcoin socat tcp-listen:9980,reuseaddr,fork tcp:localhost:8000 & "$@"
fi

echo "run some: $@"
exec "$@"