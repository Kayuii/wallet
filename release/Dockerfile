FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 0.14.0.3
ENV BITCOIN_URL https://github.com/dashpay/dash/releases/download/v${BITCOIN_VERSION}/dashcore-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 28d45537e1c982967075742f9f6ff631d6de72d075091d53ff039ed8919714ba

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& sha256sum "bitcoin.tar.gz" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.dashcore \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.dashcore
VOLUME /opt/blockchain/data

COPY ./release/docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 9998 9999 19998 19999
CMD ["dashd"]