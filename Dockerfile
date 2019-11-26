FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_DATA=/opt/blockchain/data
ENV BITCOIN_PREFIX=/opt/bitbaycoin
ENV PATH=${BITCOIN_PREFIX}:$PATH

ADD testnet-bitbayd_linux64.tgz ${BITCOIN_PREFIX}

RUN mkdir -p "$BITCOIN_DATA" "$BITCOIN_PREFIX" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitbay \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitbay \
	&& chown -R bitcoin:bitcoin "$BITCOIN_PREFIX" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_PREFIX"/bitbayd \
	&& chmod -R a+x "$BITCOIN_PREFIX" \
	&& echo "export PATH=$BITCOIN_PREFIX:$PATH" >> /etc/profile


WORKDIR ${BITCOIN_DATA}
VOLUME ${BITCOIN_DATA}

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 21914 21915
CMD ["bitbayd"]