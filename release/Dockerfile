FROM debian:stretch-slim as builder

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget unzip \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 1.1.0.0
ENV BITCOIN_URL https://github.com/ScrivNetwork/scriv/releases/download/1.1.0/Scriv-Linux-x86-1.1.0.0.zip
ENV BITCOIN_SHA256 664a31019c1fc3d4ac1d7f56326987b7133b2a7c5e6b3e70fa9d116e0861f020   
# ca4db5e7bfc938e8a7968971b6c76dd0b742ed4184fd36e2112a8434ea00a2ce

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.zip "$BITCOIN_URL" \
	&& sha256sum bitcoin.zip \
	&& echo "$BITCOIN_SHA256 bitcoin.zip" | sha256sum -c - \
	&& unzip bitcoin.zip -d /usr/local/bin/ -x *-tx \
	&& chmod +x /usr/local/bin/scriv* \
	&& rm -rf /tmp/*

	# && tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt --exclude=*-tx --exclude=test-* \
	# && rm -rf /tmp/*

FROM debian:buster-slim 

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu libboost-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

ENV BITCOIN_DATA=/opt/blockchain/data

COPY --from=builder /usr/local/bin/scriv* /usr/local/bin/

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.scriv \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.scriv

COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 7979 7998  17979  17998

CMD ["scrivd", "-daemon=0", "-server=0"]

# FROM alpine:3.8

# RUN addgroup -S bitcoin && adduser -S -D -g bitcoin bitcoin

# ENV BITCOIN_ROOT=/opt/blockchain 
# ENV BITCOIN_DATA="${BITCOIN_ROOT}/data"

# COPY --from=builder --chown=root:root /usr/local/bin/scriv* /usr/local/bin/
# COPY --from=builder --chown=bitcoin:bitcoin /usr/local/bin/scriv* ${BITCOIN_ROOT}/bin/

# RUN mkdir -p $BITCOIN_ROOT \
#     && mkdir -p $BITCOIN_DATA \
#     && ln -sfn $BITCOIN_DATA /home/bitcoin/.scriv \
# 	&& chown -h bitcoin:bitcoin /home/bitcoin/.scriv

# RUN apk update && \
#     apk upgrade && \
#     apk add --no-cache libressl boost libevent libtool libzmq su-exec

# WORKDIR ${BITCOIN_DATA}
# VOLUME ["${BITCOIN_DATA}"]

# COPY ./release/docker-entrypoint.sh /entrypoint.sh
# # RUN chmod u+x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]

# # # Port, RPC, Test Port, Test RPC
# EXPOSE 7979 7998  17979  17998

# CMD ["scrivd"]
