FROM debian:stretch-slim as builder

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 4.2.0
ENV BITCOIN_URL https://github.com/blocknetdx/blocknet/releases/download/v${BITCOIN_VERSION}/blocknet-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 3189bd12480ff14af31d3392ec2f0213082326746846f4a6ab6c676eca16c39e

RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt --exclude=*-tx --exclude=*-wallet  --exclude=test_* \
	&& rm -rf /tmp/*

FROM debian:stretch-slim 

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_DATA=/opt/blockchain/data

COPY --from=builder /usr/local/bin/blocknet* /usr/local/bin/

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.blocknetd \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.blocknetd

COPY ./releases/docker-entrypoint.sh /entrypoint.sh

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 41412 41414 41474 41419

CMD ["blocknetd", "-daemon=0", "-server=0"]
