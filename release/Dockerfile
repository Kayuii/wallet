FROM debian:buster-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION v0.17.0.3
ENV BITCOIN_URL https://github.com/Pigeoncoin/pigeoncoin/releases/download/v0.17.0.3/pigeoncoin-0.17.0-x86_64-linux-gnu.tar.gz
# ENV BITCOIN_SHA256 e11d241a8c726abd5c06a091726f0c8a4f92b3506388292b38ce41d7ba95b7c7
# && echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directoryd
ENV BITCOIN_DATA /opt/blockchain/data
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /opt/blockchain/data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8756 8757 18756 18757
CMD ["pigeond"]