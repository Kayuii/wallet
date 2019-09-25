#!/bin/bash
set -e

if [[ "$1" == "dash-cli" || "$1" == "dash-tx" || "$1" == "dashd" || "$1" == "test_dash" ]]; then
	mkdir -p "$BITCOIN_DATA"

	if [[ ! -s "$BITCOIN_DATA/dash.conf" ]]; then
		cat <<-EOF > "$BITCOIN_DATA/dash.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
EOF
		chown bitcoin:bitcoin "$BITCOIN_DATA/dash.conf"
	fi

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R bitcoin "$BITCOIN_DATA"
	ln -sfn "$BITCOIN_DATA" /home/bitcoin/.dashcore
	chown -h bitcoin:bitcoin /home/bitcoin/.dashcore

	exec gosu bitcoin "$@"
fi

exec "$@"