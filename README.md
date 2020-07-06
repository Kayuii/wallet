# wallet

### Running dcrd
You can run a decred node from inside a docker container. To build the image yourself, use the following command:
```
docker build -t decred/dcrd .
```
You may wish to use an external volume to customize your config and persist the data in an external volume:
```
docker run --rm -ti --name=dcrd-1 -v /home/user/dcrdata:/opt/blockchain/data decred/dcrd
```
Run the following command to create a wallet:
```
docker exec -ti dcrd-1 dcrwallet -u rpcuser -P rpcpass --create
```
Run the following command to start dcrwallet:
```
docker exec -ti dcrd-1 dcrwallet dcrwallet -u rpcuser -P rpcpass
```
config dcrwallet privpass and reboot docker container, docker run dcrwallet dcrd together

