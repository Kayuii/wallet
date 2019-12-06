#!/bin/bash
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for pigeond"

  set -- pigeond "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "pigeond" ]; then
  mkdir -p "$BITCOIN_DATA"

# port=7721
# rpcport=7722

  if [ ! -s "$BITCOIN_DATA/pigeon.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/pigeon.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA
dbcache=256
maxmempool=512
listen=1
server=1
logtimestamps=1
logips=1
rpcthreads=8
rpctimeout=15
rpcclienttimeout=15
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/pigeon.conf"
  fi

  chown -R bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.pigeon
  chown -h bitcoin:bitcoin /home/bitcoin/.pigeon

  echo "$0: setting data directory to $BITCOIN_DATA"

  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "pigeond" ] || [ "$1" = "pigeond-cli" ] || [ "$1" = "pigeond-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"