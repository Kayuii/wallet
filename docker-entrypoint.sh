#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for vdsd"
  set -- vdsd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "vdsd" ]; then
mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/vds.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/vds.conf"
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
    chown bitcoin:bitcoin "$BITCOIN_DATA/vds.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.vds 
	chown -h bitcoin:bitcoin /home/bitcoin/.vds 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "vdsd" ] || [ "$1" = "vds-cli" ] || [ "$1" = "vds-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
