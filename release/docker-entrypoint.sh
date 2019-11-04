#!/bin/bash
set -e

if [[ "$1" == "streamitcoin-cli" || "$1" == "streamitcoin-tx" || "$1" == "streamitcoind" ]]; then
	mkdir -p "$BITCOIN_DATA"

	if [[ ! -s "$BITCOIN_DATA/streamitcoin.conf" ]]; then
		cat <<-EOF > "$BITCOIN_DATA/streamitcoin.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
EOF
		chown bitcoin:bitcoin "$BITCOIN_DATA/streamitcoin.conf"
	fi

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R bitcoin "$BITCOIN_DATA"
	ln -sfn "$BITCOIN_DATA" /home/bitcoin/.streamitcoin
	chown -h bitcoin:bitcoin /home/bitcoin/.streamitcoin

	exec gosu bitcoin "$@"
fi

exec "$@"