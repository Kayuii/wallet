FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 0.22.5
ENV BITCOIN_URL https://github.com/Bitcoin-ABC/bitcoin-abc/releases/download/v${BITCOIN_VERSION}/bitcoin-abc-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 6a1341a513d4ad66f3b2b6b6aa59f1df497a7d6975b30b3e88a6c153ac0b1c71

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data

RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /opt/blockchain/data

COPY ./release/docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333
CMD ["bitcoind"]