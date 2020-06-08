#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for lightpaycoind"
  set -- lightpaycoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "lightpaycoind" ]; then
mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_DATA/lightpaycoin.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/lightpaycoin.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
dbcache=256
maxmempool=512
maxmempoolxbridge=128     
port=39797 
rpcport=39798 
listen=1 
server=1 
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15 
addnode=1.251.44.185:42042
addnode=104.237.144.182:39797
addnode=107.172.142.102:54158
addnode=140.82.52.41:39797
addnode=140.82.59.158:59752
addnode=142.93.109.81:39797
addnode=142.93.61.69:44318
addnode=144.202.100.107:43262
# Masternode config file
addnode=149.28.164.29:41626
addnode=149.28.195.126:39797
addnode=167.179.65.75:51640
addnode=167.86.84.212:46418
addnode=172.104.147.201:53768
addnode=172.104.245.114:39797
addnode=173.249.35.158:42640
addnode=185.49.243.36:44596
addnode=195.201.27.6:39797
addnode=202.182.119.89:39797
addnode=207.148.23.148:39797
addnode=209.50.61.28:39797
addnode=217.119.146.74:39797
addnode=217.61.57.184:39797
addnode=24.98.96.255:60859
addnode=45.32.165.237:49504
addnode=45.33.8.201:39797
addnode=45.63.116.255:39324
addnode=45.63.25.222:39797
addnode=45.77.121.44:35614
addnode=45.77.53.173:57394
addnode=45.77.58.29:36078
addnode=45.77.66.4:39797
addnode=46.101.53.185:39797
addnode=5.189.135.231:49686
addnode=51.15.251.218:39797
addnode=51.38.41.160:57240
addnode=51.83.27.253:57302
addnode=54.36.121.237:42964
addnode=54.36.175.160:39797
addnode=66.175.213.145:35260
addnode=66.228.33.23:39797
addnode=89.40.15.134:52216
addnode=95.179.147.32:48168
addnode=95.179.162.205:39797
addnode=95.179.171.132:34484
addnode=95.179.201.252:42444
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/lightpaycoin.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.lightpaycoin 
	chown -h bitcoin:bitcoin /home/bitcoin/.lightpaycoin 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "lightpaycoind" ] || [ "$1" = "lightpaycoin-cli" ] || [ "$1" = "lightpaycoin-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
