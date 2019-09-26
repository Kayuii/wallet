FROM debian:stretch-slim as builder

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates git p7zip p7zip-full \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION v0.15.1.7
ENV BITCOIN_URL https://github.com/BitcoinHot/bitcoinhot.git

RUN mkdir -p /opt/bitcoin \
  && cd /opt/bitcoin \
  && git clone --depth 1 --branch master ${BITCOIN_URL} \
  && mv ./bitcoinhot/bitcoinhot-linux.7z ./bitcoin.7z \
  && 7z x bitcoin.7z -o./bth -x\!bitcoinhot-qt

FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*


ENV BITCOIN_DATA=/opt/blockchain/data
ENV BITCOIN_PREFIX=/opt/bitcoinhot
ENV PATH=${BITCOIN_PREFIX}:$PATH

COPY --from=builder /opt/bitcoin/bth ${BITCOIN_PREFIX}

# RUN ls -alh ${BITCOIN_PREFIX}

# create data directory
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoinhot \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoinhot \
	&& chown -R bitcoin:bitcoin "$BITCOIN_PREFIX" \
	&& chmod -R a+x "$BITCOIN_PREFIX" \
	&& echo "export PATH=$BITCOIN_PREFIX:$PATH" >> /etc/profile

WORKDIR ${BITCOIN_DATA}
VOLUME ${BITCOIN_DATA}

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 7721 7722 17721 17722 17444
CMD ["bitcoinhotd"]