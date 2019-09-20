#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for bitcoinhotd"

  set -- bitcoinhotd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "/opt/bitcoinhot/bitcoinhotd" ]; then
  mkdir -p "$BITCOIN_DATA"


  if [ ! -s "$BITCOIN_DATA/bitcoinhot.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/bitcoinhot.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
dbcache=256 
maxmempool=512 
port=7721 
rpcport=7722 
listen=1 
server=1 
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/bitcoinhot.conf"
  fi

  chown -R bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoinhot 
	chown -h bitcoin:bitcoin /home/bitcoin/.bitcoinhot 

  echo "$0: setting data directory to $BITCOIN_DATA"

  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "/opt/bitcoinhot/bitcoinhotd" ] || [ "$1" = "/opt/bitcoinhot/bitcoinhotd-cli" ] || [ "$1" = "/opt/bitcoinhot/bitcoinhotd-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
