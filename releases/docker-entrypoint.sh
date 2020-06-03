#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for dappcoind"
  set -- dappcoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "dappcoind" ]; then
  mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/dappcoin.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/dappcoin.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
dbcache=256
maxmempool=512
maxmempoolxbridge=128     
port=12321 
rpcport=12322 
listen=1 
server=1 
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15
staking=1
masternode=1 
masternodeprivkey=43KigqYjtryYSTspTBUZuhN1TXdcm1R7c2A2wRjf3gVfcHkCB8G
masternodeaddr=XX.XX.XX.X:12321
addnode=seed1.dapper.link
addnode=seed2.dapper.link
addnode=seed3.dapper.link
addnode=seed4.dapper.link
addnode=seed5.dapper.link
addnode=seed6.dapper.link
addnode=seed7.dapper.link
addnode=seed8.dapper.link
addnode=seed9.dapper.link
addnode=seed10.dapper.link
addnode=seed11.dapper.link
addnode=seed12.dapper.link
addnode=seed13.dapper.link
addnode=seed14.dapper.link
addnode=seed15.dapper.link
addnode=seed16.dapper.link
addnode=seed17.dapper.link
addnode=seed18.dapper.link
addnode=seed19.dapper.link
addnode=seed20.dapper.link
addnode=seed21.dapper.link
addnode=seed22.dapper.link
addnode=seed23.dapper.link
addnode=seed24.dapper.link
addnode=seed25.dapper.link
addnode=seed26.dapper.link
addnode=seed27.dapper.link
addnode=seed28.dapper.link
addnode=seed29.dapper.link
addnode=seed30.dapper.link
addnode=seed31.dapper.link
addnode=seed32.dapper.link
addnode=seed33.dapper.link
addnode=seed34.dapper.link
addnode=seed35.dapper.link
addnode=seed36.dapper.link
addnode=seed37.dapper.link
addnode=seed38.dapper.link
addnode=seed39.dapper.link
addnode=seed40.dapper.link
addnode=seed41.dapper.link
addnode=seed42.dapper.link
addnode=seed43.dapper.link
addnode=seed44.dapper.link
addnode=seed45.dapper.link
addnode=seed46.dapper.link
addnode=seed47.dapper.link
addnode=seed48.dapper.link
addnode=seed49.dapper.link
addnode=seed50.dapper.link 
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/dappcoin.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.dappcoin 
	chown -h bitcoin:bitcoin /home/bitcoin/.dappcoin 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "dappcoind" ] || [ "$1" = "dappcoin-cli" ] || [ "$1" = "dappcoin-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
