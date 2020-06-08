FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 4.0.0
ENV BITCOIN_URL https://github.com/Deviantcoin/Source/releases/download/4.0.0.0/deviant-4.0.0-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 85112bd9e9b926475c0a04d36be4e314fb26cae65e9e3a8ecb8bee3fd2b6fe24

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt --exclude=*-tx --exclude=test-* \
	&& rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.DeviantCore \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.DeviantCore
VOLUME /opt/blockchain/data

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 22618 22617 32618 32617
CMD ["deviantd"]