#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for VERGEd"
  set -- VERGEd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "VERGEd" ]; then
mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/VERGE.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/VERGE.conf"
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
port=21102 
rpcport=20102 
rpcbind=127.0.0.1:20102
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/VERGE.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.VERGE 
	chown -h bitcoin:bitcoin /home/bitcoin/.VERGE 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "VERGEd" ] || [ "$1" = "VERGE-cli" ] || [ "$1" = "VERGE-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
