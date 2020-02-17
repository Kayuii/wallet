FROM ubuntu:bionic

ARG cores=4
ENV ecores=$cores
ENV BCHSV_VER=v1.0.2

RUN apt update \
  && apt install -y --no-install-recommends \
     software-properties-common \
     ca-certificates \
     wget curl git python vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:bitcoin/bitcoin \
  && apt update \
  && apt install -y --no-install-recommends \
     build-essential libtool autotools-dev bsdmainutils \
     libevent-dev autoconf automake pkg-config libssl-dev \
     libdb4.8-dev libdb4.8++-dev python-setuptools cmake \
     libcap-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# gcc 8
RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
  && apt update \
  && apt install -y --no-install-recommends \
     g++-8-multilib gcc-8-multilib binutils-gold \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PROJECTDIR=/opt/bitcoin/bitcoin-sv
ENV BASEPREFIX=$PROJECTDIR/depends
ENV HOST=x86_64-pc-linux-gnu

# Copy source files
RUN mkdir -p /opt/bitcoin \
  && cd /opt/bitcoin \
  && git clone --depth 1 --branch $BCHSV_VER https://github.com/bitcoin-sv/bitcoin-sv.git

# Build source
RUN mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.bitcoin \
  && cd $BASEPREFIX \
  && make -j$ecores && make install \
  && cd $PROJECTDIR \
  && chmod +x ./autogen.sh; sync \
  && ./autogen.sh \
  && CONFIG_SITE=$BASEPREFIX/$HOST/share/config.site ./configure CC=gcc-8 CXX=g++-8 CFLAGS='-Wno-deprecated' CXXFLAGS='-Wno-deprecated' --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --without-gui --enable-hardening --prefix=/ \
  && echo "Building with cores: $ecores" \
  && make -j$ecores \
  && make install

# Write default bitcoin.conf (can be overridden on commandline)
RUN echo "datadir=/opt/blockchain/data    \n\
                                          \n\
dbcache=256                               \n\
maxmempool=512                            \n\
maxmempoolxbridge=128                     \n\
                                          \n\
port=8333    # testnet: 18333            \n\
rpcport=8332 # testnet: 19332            \n\
                                          \n\
listen=1                                  \n\
server=1                                  \n\
logtimestamps=1                           \n\
logips=1                                  \n\
                                          \n\
rpcallowip=127.0.0.1                      \n\
rpctimeout=15                             \n\
rpcclienttimeout=15" > /opt/blockchain/config/bitcoin.conf

WORKDIR /opt/blockchain/
VOLUME ["/opt/blockchain/config", "/opt/blockchain/data"]

# Port, RPC, Test Port, Test RPC
EXPOSE 8333 8332  18333  18332

CMD ["/opt/blockchain/bitcoind", "-daemon=0", "-server=0"]