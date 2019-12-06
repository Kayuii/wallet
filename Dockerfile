FROM ubuntu:18.04

ARG cores=4
ENV ecores=$cores
ENV VER=v0.17.0.3

# install build tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends  software-properties-common\
  build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 git libboost-all-dev\ 
  # cleanup
  && rm -rf /var/lib/apt/lists/*

# install libdb
RUN add-apt-repository ppa:bitcoin/bitcoin -y \
  && apt-get update \
  && apt-get install -y --no-install-recommends libdb4.8-dev libdb4.8++-dev \
  # cleanup
  && rm -rf /var/lib/apt/lists/* \
  && apt-get remove -y software-properties-common 

# Build source
RUN mkdir -p /opt/pigeond \
  && mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.pigeond \
  && cd /opt/pigeond \
  && mkdir pigeond \
  && git clone --depth 1 --branch $VER https://github.com/Pigeoncoin/pigeoncoin.git pigeond \
  && cd /opt/pigeond/pigeond/

RUN cd /opt/pigeond/pigeond/ \
  && export CC="gcc -fPIC"  \
  && export CXX="g++ -fPIC"  \
  && ./autogen.sh  \
  && ./configure --enable-cxx --disable-shared --with-pic --without-gui \
  && make  \
  && make install \
  && cp /opt/pigeond/pigeond/src/pigeond /opt/blockchain/pigeond \
  && cp /opt/pigeond/pigeond/src/pigeon-cli /opt/blockchain/pigeon-cli \
  && rm -rf /opt/pigeond/

  # --enable-cxx --disable-shared --with-pic CXXFLAGS="-fPIC -O" CPPFLAGS="-fPIC -O"

# Write default pigeond.conf (can be overridden on commandline)
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
rpcclienttimeout=15                     \n" > /opt/blockchain/config/pigeond.conf

WORKDIR /opt/blockchain/
VOLUME ["/opt/blockchain/config", "/opt/blockchain/data"]

# Port, RPC, Test Port, Test RPC
EXPOSE 8756 8757 18756 18757

CMD ["/opt/blockchain/pigeond", "-daemon=0"]