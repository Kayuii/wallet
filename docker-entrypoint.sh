#!/bin/sh
set -e

export PATH="${BITCOIN_ROOT}/bin:$PATH"
if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for digibyted"

  set -- digibyted "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "digibyted" ]; then
  mkdir -p "$BITCOIN_DATA"

  if [ ! -s "$BITCOIN_DATA/digibyte.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/digibyte.conf"
printtoconsole=1
datadir=$BITCOIN_DATA
dbcache=256
maxmempool=512
port=12024
rpcport=14022
rpcbind=0.0.0.0:14022
listen=1
server=1
maxconnections=16
logtimestamps=1
logips=1
rpcallowip=::/0
rpcthreads=8
rpctimeout=15
rpcclienttimeout=15
EOF
    chown bitcoin:bitcoin "$BITCOIN_DATA/digibyte.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin 
	chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin 

  echo "$0: setting data directory to $BITCOIN_DATA"

  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "digibyted" ] || [ "$1" = "digibyte-cli" ] || [ "$1" = "bitcoin-tx" ]; then
  echo "run : $@ "
  exec su-exec bitcoin "$@"
fi

echo "run some: $@"
exec "$@"