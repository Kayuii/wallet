# Dockerfile fork from https://github.com/blocknetdx/dockerimages.git branch verge-v6.16.5.1
# Build via docker:
# docker build --build-arg cores=8 -t blocknetdx/dgb:latest .
FROM ubuntu:bionic as builder

ARG cores=1
ENV ecores=$cores
ENV VER=v6.0.2

RUN apt update \
  && apt install -y --no-install-recommends \
     software-properties-common \
     ca-certificates \
     wget curl git python vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:bitcoin/bitcoin \
  && apt update \
  && apt install -y --no-install-recommends \
     curl build-essential libtool autotools-dev \
     python3 bsdmainutils cmake libevent-dev autoconf automake \
     pkg-config libssl-dev libboost-system-dev libboost-filesystem-dev \
     libboost-chrono-dev libboost-program-options-dev libboost-test-dev \
     libboost-thread-dev libdb4.8-dev libdb4.8++-dev libgmp-dev \
     libminiupnpc-dev libzmq3-dev libcap-dev libncap-dev libqrencode-dev \
     libqt5core5a libqt5dbus5 libqt5gui5 \
     libseccomp-dev libsqlite3-dev protobuf-compiler qt5-default qtbase5-dev \
     qtdeclarative5-dev qttools5-dev qttools5-dev-tools zlib1g-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PROJECTDIR=/opt/blocknet/repo
ENV BASEPREFIX=$PROJECTDIR/depends
ENV HOST=x86_64-pc-linux-gnu

RUN mkdir -p /opt/blocknet \
  && cd /opt/blocknet \
  && git clone --depth 1 --branch $VER https://github.com/vergecurrency/verge.git repo 

# # Build source
# RUN mkdir -p /opt/blockchain/config \
#   && mkdir -p /opt/blockchain/data \
#   && ln -s /opt/blockchain/config /root/.verge \
#   && cd $BASEPREFIX \
#   && make NO_QT=1 -j8 && make install 
  
RUN cd $PROJECTDIR \
  && chmod +x ./autogen.sh ./share/genbuild.sh \
  && ./autogen.sh \
  && CONFIG_SITE=$BASEPREFIX/$HOST/share/config.site ./configure CC=gcc-8 CXX=g++-8 \
    CFLAGS='-Wno-deprecated' CXXFLAGS='-Wno-deprecated' \
    --disable-tests --disable-bench --disable-ccache --disable-maintainer-mode --disable-dependency-tracking \
    --without-gui --with-gui=no --with-utils --with-libs --with-daemon --enable-hardening --prefix=/ \
  && echo "Building with cores: $ecores" \
  && make -j$ecores \
  && strip src/verged \
  && strip src/verge-tx \
  && strip src/verge-cli \
  && make install 

FROM debian:stretch-slim 

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

ENV BITCOIN_DATA=/opt/blockchain/data

COPY --from=builder /bin/verge* /usr/local/bin/

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.verge \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.verge

COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 21102 20102 21104 21102

CMD ["verged", "-daemon=0", "-server=0"]
