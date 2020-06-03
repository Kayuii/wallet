FROM debian:stretch-slim as builder

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget unzip \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 1.0.0.1

ENV BITCOIN_URL https://github.com/dapperlink/DappCoin/releases/download/V${BITCOIN_VERSION}/ubuntu.zip

RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.zip "$BITCOIN_URL" \
	&& unzip bitcoin.zip -d /tmp \
	&& cp /tmp/16.04/dappcoind /usr/local \
	&& cp /tmp/16.04/dappcoin-cli /usr/local \
	&& rm -rf /tmp/*

FROM debian:stretch-slim 

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_DATA=/opt/blockchain/data

COPY --from=builder /usr/local/bin/dappcoin* /usr/local/bin/

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.dappcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.dappcoin

COPY ./releases/docker-entrypoint.sh /entrypoint.sh

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 9333 9332 19333 19332

CMD ["dappcoind", "-daemon=0", "-server=0"]
