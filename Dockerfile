FROM debian:stretch-slim as builder

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates git p7zip p7zip-full \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION v0.15.1.7
ENV BITCOIN_URL https://github.com/BitcoinHot/Bitcoinhot-EOL.git

RUN mkdir -p /opt/bitcoin \
  && cd /opt/bitcoin \
  && git clone --depth 1 --branch master ${BITCOIN_URL} repo \
  && mv ./repo/bitcoinhot-linux.7z ./bitcoin.7z \
  && 7z x bitcoin.7z -o./bth -x\!bitcoinhot-qt

FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/bitcoin/bth/* /usr/local/bin/

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoinhot \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoinhot
VOLUME /opt/blockchain/data

WORKDIR ${BITCOIN_DATA}
VOLUME ${BITCOIN_DATA}

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 7721 7722 17721 17722 17444
CMD ["bitcoinhotd"]