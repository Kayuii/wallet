#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for deviantd"
  set -- deviantd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "deviantd" ]; then
mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/deviant.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/deviant.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
dbcache=256
maxmempool=512
maxmempoolxbridge=128     
port=22618 
rpcport=22617 
listen=1 
server=1 
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
addnode=209.97.131.147
addnode=209.97.139.20
addnode=209.97.139.2
addnode=206.189.155.48
addnode=167.99.234.81
addnode=138.197.146.236
addnode=209.97.131.20
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/deviant.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.DeviantCore 
	chown -h bitcoin:bitcoin /home/bitcoin/.DeviantCore 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "deviantd" ] || [ "$1" = "deviant-cli" ] || [ "$1" = "deviant-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
