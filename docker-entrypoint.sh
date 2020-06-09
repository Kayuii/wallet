#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for viacoind"
  set -- viacoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "viacoind" ]; then
mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/viacoin.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/viacoin.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
dbcache=256
maxmempool=512
maxmempoolxbridge=128     
port=5223 
rpcport=5222 
rpcbind=127.0.0.1:5222
listen=1 
server=1 
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/viacoin.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.viacoin 
	chown -h bitcoin:bitcoin /home/bitcoin/.viacoin 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "viacoind" ] || [ "$1" = "viacoin-cli" ] || [ "$1" = "viacoin-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
