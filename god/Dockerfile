FROM ubuntu:xenial

ARG cores=4
ENV ecores=$cores
ENV GOD_VER=v0.1.5.0

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

# fix https://github.com/BitcoinGod/BitcoinGod/issues/1 for ubuntu 18.04
# RUN apt install -y --no-install-recommends libssl1.0-dev \
#   && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Build source
RUN mkdir -p /opt/bitcoingod \
  && mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.bitcoingod \
  && cd /opt/bitcoingod \
  && mkdir bitcoingod \
  && git clone --depth 1 --branch $GOD_VER https://github.com/bitcoingod/bitcoingod bitcoingod \
  && cd /opt/bitcoingod/bitcoingod/ \
  && cd depends \
  && make -j$ecores NO_QT=1 \
  && cd .. \
  && chmod +x ./autogen.sh \
  && ./autogen.sh \
  && ./configure --with-gui=no --enable-hardening --prefix=`pwd`/depends/x86_64-pc-linux-gnu \
  && make -j$ecores \
  && cp /opt/bitcoingod/bitcoingod/src/bitcoingodd /opt/blockchain/bitcoingodd \
  && cp /opt/bitcoingod/bitcoingod/src/bitcoingod-cli /opt/blockchain/bitcoingod-cli \
  && rm -rf /opt/bitcoingod/

# Write default bitcoingod.conf (can be overridden on commandline)
RUN echo "datadir=/opt/blockchain/data  \n\
                                        \n\
dbcache=256                             \n\
maxmempool=512                          \n\
port=8885                               \n\
rpcport=8886                            \n\
listen=1                                \n\
server=1                                \n\
logtimestamps=1                         \n\
logips=1                                \n\
rpcthreads=8                            \n\
rpcallowip=127.0.0.1                    \n\
rpctimeout=15                           \n\
rpcclienttimeout=15                     \n" > /opt/blockchain/config/bitcoingod.conf

WORKDIR /opt/blockchain/
VOLUME ["/opt/blockchain/config", "/opt/blockchain/data"]

# Port, RPC, Test Port, Test RPC
EXPOSE 8885 8886 18885 18886

CMD ["/opt/blockchain/bitcoingodd", "-daemon=0"]