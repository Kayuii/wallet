FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 5.0.0.0
ENV BITCOIN_URL https://github.com/IOCoin/DIONS/releases/download/DIONS-SIRIUS-v5.0.0.0-g5729cf1/dions-aurora-deb.sh
ENV BITCOIN_SHA256 c1c81a65ecdb4782b2550d153b8327a7d9c4e7efc1efe1eb4b0f7814f25c336a

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.sh "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 bitcoin.sh" | sha256sum -c - \
	&& chmod +x bitcoin.sh \
	&& ./bitcoin.sh \
	&& rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.iocoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.iocoin
VOLUME /opt/blockchain/data

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 33764 33765 43764 43765
CMD ["iocoind"]