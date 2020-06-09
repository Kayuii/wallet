FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
  && apt-get update \
  && apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget unzip libgomp1 \
  && rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION v3000457
ENV BITCOIN_URL https://github.com/Snowgem/Snowgem/releases/download/v3000457-20190909/snowgem-debian9.11.0-3000457-20190926.zip
ENV BITCOIN_SHA256 c5583bd31c8de86b19c481cf2c6445ebc1129e74fafc05e205064eb776ca96d3

# install bitcoin binaries
RUN set -ex \
  && cd /tmp \
  && wget -qO bitcoin.zip "$BITCOIN_URL" \
  && echo "$BITCOIN_SHA256 bitcoin.zip" | sha256sum -c - \
  && unzip bitcoin.zip -d /usr/local/bin/ \
  && rm -rf /tmp/*

  # && tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt --exclude=*-tx --exclude=test_* \
  # && rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data
ENV BITCOIN_ROOT /opt/blockchain/

RUN mkdir -p "$BITCOIN_ROOT" \
  && mkdir -p "$BITCOIN_DATA" \
  && chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
  && ln -sfn "$BITCOIN_DATA" /home/bitcoin/.snowgem \
  && chown -h bitcoin:bitcoin /home/bitcoin/.snowgem

VOLUME /opt/blockchain/data

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 16113 8333 26113 18333
CMD ["snowgemd"]