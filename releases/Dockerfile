FROM debian:stretch-slim as builder

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 3.14.0
ENV BITCOIN_URL https://github.com/blocknetdx/blocknet/releases/download/v3.14.0/blocknetdx-3.14.0-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 24a185429a2432ee9f62331c17bc76e29a3cb9818c5ae3e207a05de92af8dd25

RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

FROM debian:stretch-slim 

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_DATA=/opt/blockchain/data

COPY --from=builder /usr/local/bin/blocknetdx* /usr/local/bin/

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.blocknetdx \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.blocknetdx

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 41412 41414 41474 41419

CMD ["blocknetdxd", "-daemon=0", "-server=0"]
