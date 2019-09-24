FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 1.14.0
ENV BITCOIN_URL https://github.com/dogecoin/dogecoin/releases/download/v1.14.0/dogecoin-1.14.0-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 ed7baccafab98b5ce452bd3fd2cf7ab5e757269105350283e2bab91e4ccb7366

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& sha256sum "bitcoin.tar.gz" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /data
RUN mkdir "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.dogecoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.dogecoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# RPC PORT 
EXPOSE 22555 22556 32555 32556
CMD ["dogecoind"]