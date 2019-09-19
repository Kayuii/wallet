FROM debian:9-slim



COPY bth/* /opt/bitcoinhot/


RUN chmod a+x /opt/bitcoinhot/*
VOLUME ["/root/.bitcoinhot"]

EXPOSE 7721 7722 17721 17722 17444

WORKDIR ${BITCOIN_PREFIX}

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bitcoinhotd"]


FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget git p7zip\
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION v0.15.1.7
ENV BITCOIN_URL https://github.com/BitcoinHot/bitcoinhot.git
ENV BITCOIN_DATA=/root/.bitcoinhot
ENV BITCOIN_PREFIX=/opt/bitcoinhot
ENV PATH=${BITCOIN_PREFIX}:$PATH

RUN mkdir -p /opt/bitcoin \
  && mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.blocknetdx \
  && cd /opt/bitcoin \
  && git clone --depth 1 --branch master $BITCOIN_URL \
  && mv ./bitcoinhot/bitcoinhot-linux.7z ./bitcoin.7z \
  && 7z x bitcoin.7z -o./bth \
  && mv /opt/bitcoin/bth/* $BITCOIN_PREFIX \
  && cd /opt \
  && rm -rf /opt/bitcoin  \

# create data directory
ENV BITCOIN_DATA /data
RUN mkdir "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 7721 7722 17721 17722 17444
CMD ["bitcoinhotd"]