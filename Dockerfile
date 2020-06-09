# Dockerfile fork from https://github.com/blocknetdx/dockerimages.git branch snowgem-v6.16.5.1
# Build via docker:
# docker build --build-arg cores=8 -t blocknetdx/dgb:latest .
FROM ubuntu:bionic as builder

ARG cores=1
ENV ecores=$cores
ENV VER=v3000457-20190909

RUN apt update \
  && apt install -y --no-install-recommends \
     software-properties-common \
     ca-certificates \
     wget curl git python vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential pkg-config libc6-dev m4 g++-multilib \
    autoconf libtool ncurses-dev unzip git python python-zmq \
    zlib1g-dev wget bsdmainutils automake curl libgconf-2-4 \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PROJECTDIR=/opt/blocknet/repo
ENV BASEPREFIX=$PROJECTDIR/depends
ENV HOST=x86_64-pc-linux-gnu

RUN mkdir -p /opt/blocknet \
  && cd /opt/blocknet \
  && git clone --depth 1 --branch $VER https://github.com/Snowgem/Snowgem.git repo 

# # Build source
# RUN mkdir -p /opt/blockchain/config \
#   && mkdir -p /opt/blockchain/data \
#   && ln -s /opt/blockchain/config /root/.snowgem \
#   && cd $BASEPREFIX \
#   && make -j$ecores && make install 
  
# RUN cd $PROJECTDIR \
#   && chmod +x ./autogen.sh ./share/genbuild.sh \
#   && ./autogen.sh \
#   && CONFIG_SITE=$BASEPREFIX/$HOST/share/config.site ./configure CC=gcc-8 CXX=g++-8 \
#     CFLAGS='-Wno-deprecated' CXXFLAGS='-Wno-deprecated' \
#     --disable-tests --disable-bench --disable-ccache --disable-maintainer-mode --disable-dependency-tracking \
#     --without-gui --with-gui=no --with-utils --with-libs --with-daemon --enable-hardening --prefix=/ \
#   && echo "Building with cores: $ecores" \
#   && make -j$ecores \
#   && strip src/snowgemd \
#   && strip src/snowgem-tx \
#   && strip src/snowgem-cli \
#   && make install 

RUN cd $PROJECTDIR \
  && ./zcutil/build.sh
  

FROM debian:stretch-slim 

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

ENV BITCOIN_DATA=/opt/blockchain/data

COPY --from=builder /bin/snowgem* /usr/local/bin/

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.snowgem \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.snowgem

COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 16113 16112 26113 26112

CMD ["snowgemd", "-daemon=0", "-server=0"]
