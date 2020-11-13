# kayuii/omnicored

An [omnicore](https://github.com/OmniLayer/omnicore) docker image.

## Tags


- `v0.6.0`, `latest` ([Dockerfile](https://https://github.com/Kayuii/wallet/blob/usdt/Dockerfile))
- `v0.6.0-release` ([release/Dockerfile](https://github.com/Kayuii/wallet/blob/usdt/release/Dockerfile))
- `v0.5.0-alpine` ([v0.3.0-alpine/Dockerfile](https://github.com/mpugach/docker_omnicored/blob/master/v0.5.0-alpine/Dockerfile))
## Examples

`docker-compose` example:

```yml
version: '3'

services:
  omnicored:
    image: mpugach/omnicored
    volumes:
      - omnicore:/home/bitcoin/.bitcoin
    ports:
      - "18332:18332"
    command: "-server -regtest -txindex -rpcuser=username -rpcpassword=password -rpcallowip=172.0.0.0/8 -printtoconsole"

volumes:
  omnicore:
```

command-line example:

```sh
docker run --rm --name omnicore-server -it mpugach/omnicored \
  -server -regtest -txindex -rpcuser=username \
  -rpcpassword=password -rpcallowip=172.0.0.0/8 \
  -printtoconsole
```
