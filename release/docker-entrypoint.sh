#!/bin/bash
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for siad"

  set -- siad "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "siad" ]; then
  mkdir -p "$BITCOIN_DATA"

  echo "$0: setting data directory to $BITCOIN_DATA"

  set -- "$@" --sia-directory="$BITCOIN_DATA"
fi

if [ "$1" = "siad" ] || [ "$1" = "siac" ] ; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"