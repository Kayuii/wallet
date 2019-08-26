# Dockerfile fork from https://github.com/blocknetdx/dockerimages.git branch lightpaycoin-v1.0.1.0
# Build via docker:
# docker build --build-arg cores=8 -t blocknetdx/lpc:latest .

FROM kayuii/ubuntu:xenial

ARG cores=4
ENV ecores=$cores
ENV LPC_VER=v1.0.1.0

# Build source
RUN mkdir -p /opt/lightpaycoin \
  && mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.lightpaycoin \
  && cd /opt/lightpaycoin \
  && mkdir lightpaycoin \
  && git clone --depth 1 --branch $LPC_VER https://github.com/lpcproject/LightPayCoin lightpaycoin \
  && cd /opt/lightpaycoin/lightpaycoin/ \
  && cd depends \
  && chmod +x config.* \
  && make -j$ecores NO_QT=1 \
  && cd .. \
  && chmod +x ./autogen.sh \
  && ./autogen.sh \
  && ./configure --with-gui=no --enable-hardening --prefix=`pwd`/depends/x86_64-pc-linux-gnu \
  && make -j$ecores \
  && cp /opt/lightpaycoin/lightpaycoin/src/lightpaycoind /opt/blockchain/lightpaycoind \
  && cp /opt/lightpaycoin/lightpaycoin/src/lightpaycoin-cli /opt/blockchain/lightpaycoin-cli \
  && rm -rf /opt/lightpaycoin/

# Write default lightpaycoin.conf (can be overridden on commandline)
RUN echo "datadir=/opt/blockchain/data  \n\
                                        \n\
dbcache=256                             \n\
maxmempool=512                          \n\
port=39797                               \n\
rpcport=39798                          \n\
listen=1                                \n\
server=1                                \n\
logtimestamps=1                         \n\
logips=1                                \n\
rpcthreads=8                            \n\
rpcallowip=127.0.0.1                    \n\
rpctimeout=15                           \n\
rpcclienttimeout=15                     \n" > /opt/blockchain/config/lightpaycoin.conf

WORKDIR /opt/blockchain/
VOLUME ["/opt/blockchain/config", "/opt/blockchain/data"]

# Port, RPC, Test Port, Test RPC
EXPOSE 39797 39798  18332  19332

CMD ["/opt/blockchain/lightpaycoind", "-daemon=0"]