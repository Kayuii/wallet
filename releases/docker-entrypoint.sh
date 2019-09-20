#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for blocknetdxd"
  set -- blocknetdxd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "blocknetdxd" ]; then
  mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/blocknetdx.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/blocknetdx.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
dbcache=256
maxmempool=512
maxmempoolxbridge=128     
port=41412 
rpcport=41414 
listen=1 
server=1 
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/blocknetdx.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.blocknetdx 
	chown -h bitcoin:bitcoin /home/bitcoin/.blocknetdx 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "blocknetdxd" ] || [ "$1" = "blocknetdx-cli" ] || [ "$1" = "blocknetdx-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
