FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 1.0.1.0
ENV BITCOIN_URL https://github.com/lpcproject/LightPayCoin/releases/download/v1.0.1.0/lightpaycoin-1.0.1-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 34bf1b032ebb68cfa35e34a42c82b6b91e229b631c0006b599df7c6f8dd01dc6

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt --exclude=*-tx --exclude=test_* \
	&& rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.lightpaycoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.lightpaycoin
VOLUME /opt/blockchain/data

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333
CMD ["lightpaycoind"]