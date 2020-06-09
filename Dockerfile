<<<<<<< HEAD
FROM ubuntu:bionic as builder

ARG cores=1
ENV ecores=$cores
ENV VER=v0.1.5.0

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
  && git clone --depth 1 --branch $VER https://github.com/BitcoinGod/BitcoinGod.git repo 

# # Build source
RUN mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.bitcoingod \
  && cd $BASEPREFIX \
  && make -j4 && make install 

RUN cd $PROJECTDIR \
  && chmod +x ./autogen.sh ./share/genbuild.sh \
  && ./autogen.sh \
  && CONFIG_SITE=$BASEPREFIX/$HOST/share/config.site ./configure CC=gcc-8 CXX=g++-8 \
    CFLAGS='-Wno-deprecated' CXXFLAGS='-Wno-deprecated' \
    --disable-tests --disable-bench --disable-ccache --disable-maintainer-mode --disable-dependency-tracking \
    --without-gui --with-gui=no --with-utils --with-libs --with-daemon --enable-hardening --prefix=/ \
  && echo "Building with cores: $ecores" \
  && make -j$ecores \
  && strip src/bitcoingodd \
  && strip src/bitcoingod-cli \
  && make install 

RUN cd $PROJECTDIR \
  && ./configure --help 

# FROM debian:stretch-slim 
FROM debian:buster-slim 

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

ENV BITCOIN_DATA=/opt/blockchain/data

COPY --from=builder /bin/bitcoingod* /usr/local/bin/

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoingod \
=======
FROM alpine:3.8 as builder

LABEL maintainer="Maksym Pugach <pugach.m@gmail.com>, Daniel Zhou <danichau93@gmail.com>, Jack <admin@nightc.com>, Kayuii <577738@qq.com>"

ENV BITCOIN_ROOT=/opt/blockchain
ENV BDB_PREFIX="${BITCOIN_ROOT}/db4" BITCOIN_REPO="${BITCOIN_ROOT}/repo" PATH="${BITCOIN_ROOT}/bin:$PATH" BITCOIN_DATA="${BITCOIN_ROOT}/data"
ENV BITCOIN_VER=v0.1.5.0

RUN mkdir -p $BITCOIN_ROOT \
    && mkdir -p $BDB_PREFIX \
    && mkdir -p $BITCOIN_DATA 

WORKDIR ${BITCOIN_ROOT}

RUN apk update && \
    apk upgrade && \
    apk add --no-cache libressl boost libevent libtool libzmq boost-dev libressl-dev libevent-dev zeromq-dev

RUN apk add --no-cache git autoconf automake g++ make file

RUN git clone --depth 1 --branch $BITCOIN_VER https://github.com/BitcoinGod/BitcoinGod.git $BITCOIN_REPO

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
    strip $BITCOIN_ROOT/bin/bitcoingod-cli && \
    strip $BITCOIN_ROOT/bin/bitcoingodd && \
    strip $BITCOIN_ROOT/lib/libbitcoinconsensus.a && \
    strip $BITCOIN_ROOT/lib/libbitcoinconsensus.so.0.0.0 && \
    apk del git autoconf automake g++ make file

FROM alpine:3.8

LABEL maintainer="kayuii (577738@qq.com)"

RUN addgroup -S bitcoin && adduser -S -D -g bitcoin bitcoin

ENV BITCOIN_ROOT=/opt/blockchain 
ENV BITCOIN_DATA="${BITCOIN_ROOT}/data"

RUN mkdir -p $BITCOIN_ROOT \
    && mkdir -p $BITCOIN_DATA \
    && ln -sfn $BITCOIN_DATA /home/bitcoin/.bitcoingod \
>>>>>>> 989c3d20cdf3394a08bdddec1bed65d0deb892d0
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoingod

COPY --from=builder --chown=bitcoin:bitcoin ${BITCOIN_ROOT}/bin ${BITCOIN_ROOT}/bin
COPY --from=builder --chown=bitcoin:bitcoin ${BITCOIN_ROOT}/lib ${BITCOIN_ROOT}/lib
COPY --from=builder --chown=bitcoin:bitcoin ${BITCOIN_ROOT}/include ${BITCOIN_ROOT}/include

RUN apk update && \
    apk upgrade && \
    apk add --no-cache libressl boost libevent libtool libzmq su-exec

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

COPY ./docker-entrypoint.sh /entrypoint.sh
# RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# # Port, RPC, Test Port, Test RPC
EXPOSE 8332 8333 18332 18333 18444

CMD ["bitcoingodd"]
