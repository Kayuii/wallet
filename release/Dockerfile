FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 0.16.3
ENV BITCOIN_URL https://github.com/viacoin/viacoin/releases/download/v${BITCOIN_VERSION}/viacoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 4b84d8f1485d799fdff6cb4b1a316c00056b8869b53a702cd8ce2cc581bae59a

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& sha256sum bitcoin.tar.gz \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt --exclude=*-tx --exclude=test_* \
	&& rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.viacoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.viacoin
VOLUME /opt/blockchain/data

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 5223 5222 25223 25222
CMD ["viacoind"]