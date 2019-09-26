#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for bitcoinhotd"

  set -- bitcoinhotd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "bitcoinhotd" ]; then
  mkdir -p "$BITCOIN_DATA"

chown bitcoin:bitcoin "$BITCOIN_DATA/.profile"
fi

  if [ ! -s "$BITCOIN_DATA/bitcoinhot.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/bitcoinhot.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA
dbcache=256 
maxmempool=512 
port=7721 
rpcport=7722 
listen=1 
server=1 
logtimestamps=1 
logips=1 
rpcthreads=8 
rpctimeout=15 
rpcclienttimeout=15
addnode=13.250.40.50
addnode=54.169.70.107
addnode=13.229.133.85
addnode=54.169.24.181
addnode=59.57.110.25
addnode=120.27.24.60
addnode=139.201.12.22
addnode=182.133.18.126
addnode=171.211.132.126
addnode=139.201.11.60
addnode=171.211.239.55
addnode=182.133.16.213
addnode=117.139.77.154
addnode=47.105.76.112
addnode=222.209.156.242
addnode=112.239.94.92
addnode=47.105.238.122
addnode=119.185.244.6
addnode=122.97.179.127
addnode=122.97.179.243
addnode=122.97.175.118
addnode=122.97.175.16
addnode=54.175.116.10
addnode=180.129.17.178
addnode=14.13.234.96
addnode=61.157.96.34
addnode=93.243.148.81
addnode=185.104.252.158
addnode=61.157.96.37
addnode=212.50.170.248
addnode=185.205.210.142
addnode=82.200.205.30
addnode=120.84.9.61
addnode=83.50.37.101
addnode=126.36.180.199
addnode=185.227.54.78
addnode=95.217.40.186
addnode=203.152.216.75
addnode=79.227.85.49
addnode=39.176.5.84
addnode=120.84.11.231
addnode=61.157.96.35
addnode=83.58.96.80
addnode=32.215.8.63
addnode=109.105.40.15
addnode=149.56.155.28
addnode=153.137.203.154
addnode=93.229.87.208
addnode=68.58.58.95
addnode=88.99.68.228
addnode=61.157.96.39
addnode=212.224.225.126
addnode=61.157.96.31
addnode=61.157.96.32
addnode=122.97.178.104
addnode=166.181.84.245
addnode=5.172.255.208
addnode=167.86.123.213
addnode=90.190.180.4
addnode=79.125.238.22
addnode=80.218.217.199
addnode=61.157.96.40
addnode=46.48.68.108
addnode=61.157.96.36
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/bitcoinhot.conf"
  fi

  chown -R bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoinhot 
	chown -h bitcoin:bitcoin /home/bitcoin/.bitcoinhot 

  echo "$0: setting data directory to $BITCOIN_DATA"

  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "bitcoinhotd" ] || [ "$1" = "bitcoinhotd-cli" ] || [ "$1" = "bitcoinhotd-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
