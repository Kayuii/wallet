FROM debian:buster-slim as builder


RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget unzip \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 1.4.1.2
ENV BITCOIN_URL https://sia.tech/releases/Sia-v${BITCOIN_VERSION}-linux-amd64.zip
# ENV BITCOIN_SHA256 e11d241a8c726abd5c06a091726f0c8a4f92b3506388292b38ce41d7ba95b7c7
# && echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& mkdir -p /bitcoin/ \
	&& wget -qO bitcoin.zip "$BITCOIN_URL" \
	&& unzip -d /tmp/bitcoin/ /tmp/bitcoin.zip \
    && mv /tmp/bitcoin/Sia-v${BITCOIN_VERSION}-linux-amd64/siac /bitcoin/ \
    && mv /tmp/bitcoin/Sia-v${BITCOIN_VERSION}-linux-amd64/siad /bitcoin/ \
	&& rm -rf /tmp/*

FROM debian:buster-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu curl \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_DATA /opt/blockchain/data

COPY --from=builder /bitcoin/ /bin

# create data directoryd
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.sia \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.sia
VOLUME  "$BITCOIN_DATA"
WORKDIR  "$BITCOIN_DATA"

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9980 9981 9982
CMD ["siad"]