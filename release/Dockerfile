FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 1.1.0.0
ENV BITCOIN_URL https://github.com/ScrivNetwork/scriv/releases/download/1.1.0/Scriv-Linux-x64-1.1.0.0.zip
ENV BITCOIN_SHA256 596a2f8a1d23919a9daf00686df195a50857a8aaddc40726b2ff4b364cdb6afe

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.zip "$BITCOIN_URL" \
	&& sha256sum bitcoin.zip
	&& echo "$BITCOIN_SHA256 bitcoin.zip" | sha256sum -c - \
	&& unzip -help \
	&& rm -rf /tmp/*

	# && tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt --exclude=*-tx --exclude=test-* \
	# && rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /opt/blockchain/data

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333
CMD ["bitcoind"]