#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for snowgemd"
  set -- snowgemd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "snowgemd" ]; then
mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/snowgem.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/snowgem.conf"
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
port=16113 
rpcport=16112 
rpcbind=127.0.0.1:16112
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/snowgem.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.snowgem 
	chown -h bitcoin:bitcoin /home/bitcoin/.snowgem 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "snowgemd" ] || [ "$1" = "snowgem-cli" ] || [ "$1" = "snowgem-tx" ]; then
    if [ ! -s "/home/bitcoin/.zcash-params/sprout-verifying.key" ]; then
      gosu bitcoin snowgem-fetch-params
    fi
    echo "run : $@ "
    exec gosu bitcoin "$@"    
fi

if [ ! -s "/root/.zcash-params/sprout-verifying.key" ]; then
  snowgem-fetch-params
fi
echo "run some: $@"
exec "$@"
