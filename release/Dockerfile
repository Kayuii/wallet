FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 0.6.0
ENV BITCOIN_URL https://github.com/OmniLayer/omnicore/releases/download/v${BITCOIN_VERSION}/omnicore-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SIG https://github.com/OmniLayer/omnicore/releases/download/v${BITCOIN_VERSION}/omnicore-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz.sig
# ENV BITCOIN_SHA256 e11d241a8c726abd5c06a091726f0c8a4f92b3506388292b38ce41d7ba95b7c7

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
    && wget -qO bitcoin.tar.gz.sig "$BITCOIN_SIG" \
    && gpg --list-keys \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys \
    F43718054C3E7C5CFB33E8257675E31CF5719832 \
    && gpg --batch --verify bitcoin.tar.gz.sig bitcoin.tar.gz \
 	# && echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
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

EXPOSE 8332 8333 18332 18333 18444
CMD ["omnicored"]