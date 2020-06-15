#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for rippled"
  set -- rippled "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "rippled" ]; then
mkdir -p "$BITCOIN_DATA"
  
  if [ ! -s "/etc/rippled.conf" ]; then
    cat <<EOF > "/etc/rippled.conf"
[server]
port_peer
port_rpc
port_ws_public

[port_peer]
ip=0.0.0.0
port=51235
protocol=peer
admin=127.0.0.1

[port_rpc]
ip=127.0.0.1
port=5005
protocol=http
admin=127.0.0.1

[port_ws_public]
ip=0.0.0.0
port=5006
protocol=ws,wss
admin=127.0.0.1

[database_path]
$BITCOIN_DATA

[node_db]
type=rocksdb
path=$BITCOIN_DATA
compression=1
online_delete=48000
advisory_delete=0
open_files=2000
filter_bits=12
cache_mb=256
file_size_mb=8
file_size_mult=2

[ips]
r.ripple.com 51235

[validators]
n949f75evCHwgyP4fPVgaHqNHxUVN15PsJEZ3B3HnXPcPjcZAoy7  RL1
n9MD5h24qrQqiyBC8aeqqCWvpiBiYQ3jxSr91uiDvmrkyHRdYLUj  RL2
n9L81uNCaPgtUJfaHh89gmdvXKAmSt5Gdsw2g1iPWaPkAHW5Nm4C  RL3
n9KiYM9CgngLvtRCQHZwgC2gjpdaZcCcbt3VboxiNFcKuwFVujzS  RL4
n9LdgEtkmGB9E2h3K4Vp7iGUaKuq23Zr32ehxiU8FWY7xoxbWTSA  RL5

[node_size]
large

[ledger_history]
12400

[fetch_depth]
full

[validation_quorum]
3

[sntp_servers]
time.windows.com
time.apple.com
time.nist.gov
pool.ntp.org

[rpc_startup]
{ "command": "log_level", "severity": "error" }

EOF
    # chown bitcoin:bitcoin "/etc/rippled.conf"
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  ln -sfn "$BITCOIN_DATA" /home/bitcoin/.ripple 
	chown -h bitcoin:bitcoin /home/bitcoin/.ripple 

  echo "$0: setting data directory to $BITCOIN_DATA"
  set -- "$@" -datadir="$BITCOIN_DATA"
fi

if [ "$1" = "rippled" ] || [ "$1" = "ripple-cli" ] || [ "$1" = "ripple-tx" ]; then
  echo "run : $@ "
  exec gosu bitcoin "$@"
fi

echo "run some: $@"
exec "$@"
