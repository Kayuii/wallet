FROM alpine:3.8

LABEL maintainer="kayuii (577738@qq.com)"


ENV BITCOIN_ROOT=/opt/blockchain
ENV BDB_PREFIX="${BITCOIN_ROOT}/db4" BITCOIN_REPO="${BITCOIN_ROOT}/repo" PATH="${BITCOIN_ROOT}/bin:$PATH" BITCOIN_DATA="${BITCOIN_ROOT}/data"
ENV BITCOIN_CONF="${BITCOIN_ROOT}/config"

RUN mkdir -p $BITCOIN_ROOT \
    && mkdir -p $BDB_PREFIX \
    && mkdir -p $BITCOIN_CONF \
    && mkdir -p $BITCOIN_DATA \
    && ln -s $BITCOIN_CONF /root/.bitcoin 

WORKDIR /opt/blockchain/

RUN apk update && \
    apk upgrade && \
    apk add --no-cache libressl boost libevent libtool libzmq boost-dev libressl-dev libevent-dev zeromq-dev

RUN apk add --no-cache git autoconf automake g++ make file

RUN git clone --depth 1 -b v0.5.0 https://github.com/OmniLayer/omnicore.git $BITCOIN_REPO

RUN  wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz' && \
    echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c

RUN tar -xzf db-4.8.30.NC.tar.gz
RUN cd db-4.8.30.NC/build_unix/ && \
    ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX && \
    make -j4 && \
    make install
RUN cd $BITCOIN_REPO && \
    ./autogen.sh && \
    ./configure \
        LDFLAGS="-L${BDB_PREFIX}/lib/" \
        CPPFLAGS="-I${BDB_PREFIX}/include/" \
        --disable-tests \
        --disable-bench \
        --disable-ccache \
        --with-gui=no \
        --with-utils \
        --with-libs \
        --with-daemon \
        --prefix=$BITCOIN_ROOT && \
    make -j4 && \
    make install && \
    rm -rf $BITCOIN_ROOT/db-4.8.30.NC* && \
    rm -rf $BDB_PREFIX/docs && \
    rm -rf $BITCOIN_REPO && \
    strip $BITCOIN_ROOT/bin/omnicore-cli && \
    strip $BITCOIN_ROOT/bin/bitcoin-tx && \
    strip $BITCOIN_ROOT/bin/omnicored && \
    strip $BITCOIN_ROOT/lib/libbitcoinconsensus.a && \
    strip $BITCOIN_ROOT/lib/libbitcoinconsensus.so.0.0.0 && \
    apk del git autoconf automake g++ make file

COPY ./docker-entrypoint.sh /entrypoint.sh

RUN chmod u+x /entrypoint.sh

# Write default bitcoin.conf (can be overridden on commandline)
RUN echo "datadir=${BITCOIN_DATA}  \n\
                                        \n\
dbcache=256                             \n\
maxmempool=512                          \n\
                                        \n\
port=8333    # testnet: 18333           \n\
rpcport=8332 # testnet: 18332           \n\
                                        \n\
listen=1                                \n\
server=1                                \n\
maxconnections=16                       \n\
logtimestamps=1                         \n\
logips=1                                \n\
                                        \n\
rpcallowip=127.0.0.1                    \n\
rpctimeout=15                           \n\
rpcclienttimeout=15                     \n" > $BITCOIN_CONF/bitcoin.conf


VOLUME ["${BITCOIN_CONF}", "${BITCOIN_DATA}"]

# Port, RPC, Test Port, Test RPC
EXPOSE 8332 8333 18332 18333 18444

ENTRYPOINT ["/entrypoint.sh"]

CMD ["omnicored"]
