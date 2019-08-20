#!/bin/sh
set -e

export PATH="${BITCOIN_ROOT}/bin:$PATH"
if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for omnicored"

  set -- omnicored "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "omnicored" ]; then
  mkdir -p "$BITCOIN_DATA"

  if [ ! -s "$BITCOIN_DATA/bitcoin.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/bitcoin.conf"
server=1 
listen=1
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
dbcache=256
maxmempool=512
maxmempoolxbridge=128   
maxconnections=16  
port=12024 
rpcport=14022 
rpcbind=127.0.0.1:14022
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/bitcoin.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin 
	chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin 

  echo "$0: setting data directory to $BITCOIN_DATA"

  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "omnicored" ] || [ "$1" = "omnicore-cli" ] || [ "$1" = "bitcoin-tx" ]; then
  echo "run : $@ "
  exec su-exec bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
