#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for dcrd"
  set -- dcrd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "dcrd" ]; then
mkdir -p "$BITCOIN_ROOT"
mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "$BITCOIN_ROOT/dcrd.conf" ]; then
cat <<EOF > "$BITCOIN_ROOT/dcrd.conf"
listen=:9108
rpclisten=0.0.0.0:9109
rpcpass=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
datadir=$BITCOIN_DATA 
appdata=$BITCOIN_ROOT
EOF
    chown bitcoin:bitcoin "$BITCOIN_ROOT/dcrd.conf"
  fi

  if [ ! -s "$BITCOIN_ROOT/dcrctl.conf" ]; then
cat <<EOF > "$BITCOIN_ROOT/dcrctl.conf"
rpcserver=localhost:9109
walletrpcserver=localhost:9109
rpcpass=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
rpccert=~/.dcrd/rpc.cert
EOF
    chown bitcoin:bitcoin "$BITCOIN_ROOT/dcrctl.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_ROOT"
  ln -sfn "$BITCOIN_ROOT" /home/bitcoin/.dcrd 
  ln -sfn "$BITCOIN_ROOT" /root/.dcrd 
  ln -sfn "$BITCOIN_ROOT" /root/.dcrwallet 
  ln -sfn "$BITCOIN_ROOT" /root/.dcrctl 
  ln -sfn "$BITCOIN_ROOT" /root/.dcrctl 
	chown -h bitcoin:bitcoin /home/bitcoin/.dcrd
	chown -h bitcoin:bitcoin /root/.dcrd
	chown -h bitcoin:bitcoin /root/.dcrwallet 
  

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" --appdata="$BITCOIN_ROOT" --datadir="$BITCOIN_DATA"
fi

if [ "$1" = "dcrd" ] || [ "$1" = "dcrctl" ] ; then
  echo "run : $@ "
  exec su-exec bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
