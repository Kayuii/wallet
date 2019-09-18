

bitcoingod

========

These bitcoingod images are optimized for use with the Blocknet DX.

**Note**

These images are _not a replacement or endorsement_ of the bitcoingod project (https://github.com/bitcoingod/bitcoingod).


Simple
======

Run a simple bitcoingod node on port 8885:
```
docker run -d --name=bitcoingod -p 8885:8885 blocknetdx/bitcoingod:latest
```


Persist blockchain w/ volumes
=============================

Run a bitcoingod node that persists the blockchain on a host directory. Recommended to avoid time consuming resyncs when updating to later container versions.
```
docker run -d --name=bitcoingod -p 8885:8885 -v=/crypto/bitcoingod/config:/opt/blockchain/config -v=/crypto/bitcoingod/data:/opt/blockchain/data blocknetdx/bitcoingod:latest
```


Automatically restart the container
===================================

See https://docs.docker.com/engine/admin/start-containers-automatically/

`--restart=no|on-failure:retrycount|always|unless-stopped`

```
docker run -d --restart=no --name=bitcoingod -p 8885:8885 blocknetdx/bitcoingod:latest bitcoingodd -daemon=0 -rpcuser=god -rpcpassword=god123
docker run -d --restart=on-failure:10 --name=bitcoingod -p 8885:8885 blocknetdx/bitcoingod:latest bitcoingodd -daemon=0 -rpcuser=god -rpcpassword=god123
docker run -d --restart=unless-stopped --name=bitcoin -p 8885:8885 blocknetdx/bitcoingod:latest bitcoingodd -daemon=0 -rpcuser=god -rpcpassword=god123
docker run -d --restart=always --name=bitcoin -p 8885:8885 blocknetdx/bitcoingod:latest bitcoingodd -daemon=0 -rpcuser=god -rpcpassword=god123
```


Container shell access
======================

To login to the bitcoingod container and run RPC commands use the following command:
```
docker exec -it bitcoingod /bin/bash
```


Default bitcoingod.conf
=====================

The default configuration is below. A custom configuration file can be passed to the bitcoingod  node container through the `/opt/blockchain/config` volume. Some of these parameters can also be adjusted on the command line.
```
datadir=/opt/blockchain/data

dbcache=256
maxmempool=512

port=8885    # testnet: 18885
rpcport=8886 # testnet: 18886

listen=1
server=1
logtimestamps=1
logips=1

rpcallowip=127.0.0.1
rpctimeout=15
rpcclienttimeout=15
```


License
=======

This code is licensed under the Apache 2.0 License. Please refer to the [LICENSE](https://github.com/BlocknetDX/dockerimages/blob/master/LICENSE).