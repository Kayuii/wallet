#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for scrivd"
  set -- scrivd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "scrivd" ]; then
mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/scriv.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/scriv.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
dbcache=256
maxmempool=512
maxmempoolxbridge=128     
port=7979 
rpcport=7998 
listen=1 
server=1 
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/scriv.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.scriv 
	chown -h bitcoin:bitcoin /home/bitcoin/.scriv 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "scrivd" ] || [ "$1" = "scriv-cli" ] || [ "$1" = "scriv-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
