#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for dappercoind"
  set -- dappercoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "dappercoind" ]; then
  mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/dappercoin.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/dappercoin.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
dbcache=256
maxmempool=512
maxmempoolxbridge=128     
port=9333 
rpcport=9332 
listen=1 
server=1 
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/dappercoin.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.dappercoin 
	chown -h bitcoin:bitcoin /home/bitcoin/.dappercoin 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "dappercoind" ] || [ "$1" = "dappercoin-cli" ] || [ "$1" = "dappercoin-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
