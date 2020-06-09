# Dockerfile fork from https://github.com/blocknetdx/dockerimages.git branch viacoin-v6.16.5.1
# Build via docker:
# docker build --build-arg cores=8 -t blocknetdx/dgb:latest .
FROM ubuntu:bionic as builder

ARG cores=1
ENV ecores=$cores
ENV VER=v0.16.3

RUN apt update \
  && apt install -y --no-install-recommends \
     software-properties-common \
     ca-certificates \
     wget curl git python vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:bitcoin/bitcoin \
  && apt update \
  && apt install -y --no-install-recommends \
     curl build-essential libtool autotools-dev automake \
     python3 bsdmainutils cmake libevent-dev autoconf automake \
     pkg-config libssl-dev libboost-system-dev libboost-filesystem-dev \
     libboost-chrono-dev libboost-program-options-dev libboost-test-dev \
     libboost-thread-dev libdb4.8-dev libdb4.8++-dev libgmp-dev \
     libminiupnpc-dev libzmq3-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PROJECTDIR=/opt/blocknet/repo
ENV BASEPREFIX=$PROJECTDIR/depends
ENV HOST=x86_64-pc-linux-gnu

RUN mkdir -p /opt/blocknet \
  && cd /opt/blocknet \
  && git clone --depth 1 --branch $VER https://github.com/viacoin/viacoin.git repo 

# # Build source
RUN mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.viacoin \
  && cd $BASEPREFIX \
  && make -j4 && make install \
  && cd $PROJECTDIR \
  && chmod +x ./autogen.sh ./share/genbuild.sh \
  && ./autogen.sh \
  && CONFIG_SITE=$BASEPREFIX/$HOST/share/config.site ./configure CC=gcc-8 CXX=g++-8 \
    CFLAGS='-Wno-deprecated' CXXFLAGS='-Wno-deprecated' \
    --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --disable-tests --disable-bench \
    --without-gui --with-gui=no --with-utils --with-libs --with-daemon --enable-hardening --prefix=/ \
  && echo "Building with cores: $ecores" \
  && make -j$ecores \
  && strip src/viacoind \
  && strip src/viacoin-tx \
  && strip src/viacoin-cli \
  && make install 

FROM debian:buster-slim 

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

ENV BITCOIN_DATA=/opt/blockchain/data

COPY --from=builder /bin/viacoin* /usr/local/bin/

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.viacoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.viacoin

COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 5223 5222 25223 25222

CMD ["viacoind", "-daemon=0", "-server=0"]
