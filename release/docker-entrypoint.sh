#!/bin/bash
set -e

if [[ "$1" == "digibyte-cli" || "$1" == "digibyted" ]]; then
	mkdir -p "$BITCOIN_DATA"

	if [[ ! -s "$BITCOIN_DATA/digibyte.conf" ]]; then
		cat <<-EOF > "$BITCOIN_DATA/digibyte.conf"
printtoconsole=1
rpcallowip=::/0
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
EOF
		chown bitcoin:bitcoin "$BITCOIN_DATA/digibyte.conf"
	fi

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R bitcoin "$BITCOIN_DATA"
	ln -sfn "$BITCOIN_DATA" /home/bitcoin/.digibyte
	chown -h bitcoin:bitcoin /home/bitcoin/.digibyte

	exec gosu bitcoin "$@"
fi

exec "$@"