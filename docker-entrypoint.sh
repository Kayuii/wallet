#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for dcrd"
  set -- dcrd "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "dcrd" ] ; then
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
logdir=$BITCOIN_DATA/logs
notls
EOF
    chown bitcoin:bitcoin "$BITCOIN_ROOT/dcrd.conf"
  fi

  if [ ! -s "$BITCOIN_ROOT/dcrctl.conf" ]; then
cat <<EOF > "$BITCOIN_ROOT/dcrctl.conf"
rpcserver=localhost:9109
walletrpcserver=localhost:9110
rpcpass=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
rpccert=~/.dcrd/rpc.cert
EOF
    chown bitcoin:bitcoin "$BITCOIN_ROOT/dcrctl.conf"
  fi

  if [ ! -s "$BITCOIN_ROOT/dcrwallet.conf" ]; then
cat <<EOF > "$BITCOIN_ROOT/dcrwallet.conf"
gaplimit=120000
rpclisten=0.0.0.0:9110
appdata=$BITCOIN_DATA
logdir=$BITCOIN_DATA/walletlogs
password=${BITCOIN_RPC_PASSWORD:-password}
username=${BITCOIN_RPC_USER:-bitcoin}
noservertls
# walletpass=${WALLET_PUB_PASS:-pubpass}
# pass=${WALLET_PRIV_PASS:-privpass}
EOF
    chown bitcoin:bitcoin "$BITCOIN_ROOT/dcrwallet.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_ROOT"
  ln -sfn "$BITCOIN_ROOT" /home/bitcoin/.dcrd 
  ln -sfn "$BITCOIN_ROOT" /home/bitcoin/.dcrctl 
  ln -sfn "$BITCOIN_ROOT" /home/bitcoin/.dcrwallet
  ln -sfn "$BITCOIN_ROOT" /root/.dcrd 
  ln -sfn "$BITCOIN_ROOT" /root/.dcrctl 
  ln -sfn "$BITCOIN_ROOT" /root/.dcrwallet 
	chown -h bitcoin:bitcoin /home/bitcoin/.dcrd
	chown -h bitcoin:bitcoin /home/bitcoin/.dcrctl
	chown -h bitcoin:bitcoin /home/bitcoin/.dcrwallet
	chown -h bitcoin:bitcoin /root/.dcrd
	chown -h bitcoin:bitcoin /root/.dcrctl 
	chown -h bitcoin:bitcoin /root/.dcrwallet 
  

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" --appdata="$BITCOIN_ROOT" --datadir="$BITCOIN_DATA"
fi

if [ "$1" = "dcrd" ] || [ "$1" = "dcrctl" ] ; then
  if [ -s "$BITCOIN_DATA/mainnet/wallet.db" ]; then
    echo "run : dcrwallet"
    su-exec bitcoin dcrwallet
  fi
  echo "run : $@ "
  exec su-exec bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
