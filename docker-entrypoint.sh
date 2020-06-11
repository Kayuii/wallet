#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for siad"
  set -- siad "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "siad" ]; then
  mkdir -p "$BITCOIN_DATA"
  
  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.sia 
	chown -h bitcoin:bitcoin /home/bitcoin/.sia 

  echo "$0: setting data directory to $BITCOIN_DATA"
  # set -- "$@" -datadir="$BITCOIN_DATA"
  # socat tcp-listen:9980,reuseaddr,fork tcp:localhost:8000 & siad   --modules \"$SIA_MODULES\"   --sia-directory \"$SIA_DATA_DIR\"   --api-addr \"localhost:8000\"   --authenticate-api=false
  set -- "$@" --modules="$SIA_MODULES" --sia-directory="$BITCOIN_DATA" --authenticate-api=false --api-addr=localhost:8000
fi

if [ "$1" = "siad" ]; then
  echo "run : socat tcp-listen:9980,reuseaddr,fork tcp:localhost:8000 & $@ "
  socat tcp-listen:9980,reuseaddr,fork tcp:localhost:8000 &
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
