FROM alpine:3.8 as builder

ENV BITCOIN_ROOT=/opt/blockchain
ENV BDB_PREFIX="${BITCOIN_ROOT}/db4" BITCOIN_REPO="${BITCOIN_ROOT}/repo" PATH="${BITCOIN_ROOT}/bin:$PATH" BITCOIN_DATA="${BITCOIN_ROOT}/data"
ENV BITCOIN_VER=v7.17.2

RUN mkdir -p $BITCOIN_ROOT \
  && mkdir -p $BDB_PREFIX \
  && mkdir -p $BITCOIN_DATA 

WORKDIR ${BITCOIN_ROOT}

RUN apk update \
  && apk upgrade \
  && apk add --no-cache libressl boost libevent libtool libzmq boost-dev libressl-dev libevent-dev zeromq-dev

RUN apk add --no-cache git autoconf automake g++ make file

RUN git clone --depth 1 --branch $BITCOIN_VER https://github.com/DigiByte-Core/digibyte.git $BITCOIN_REPO

RUN	wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz' \
  && echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c

RUN tar -xzf db-4.8.30.NC.tar.gz
RUN cd db-4.8.30.NC/build_unix/ \
  && ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX \
  && make -j4 \
  && make install

RUN cd $BITCOIN_REPO \
  && ./autogen.sh \
  && ./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" \
   --disable-tests --disable-bench --disable-ccache \
   --with-gui=no --with-utils --with-libs --with-daemon \
   --prefix=$BITCOIN_ROOT \
  && make -j1 \
  && make install \
  && rm -rf $BITCOIN_ROOT/db-4.8.30.NC* \
  && rm -rf $BDB_PREFIX/docs \
  && rm -rf $BITCOIN_REPO \
  && strip $BITCOIN_ROOT/bin/digibyte-cli \
  && strip $BITCOIN_ROOT/bin/digibyte-tx \
  && strip $BITCOIN_ROOT/bin/digibyted

FROM alpine:3.8

RUN set -ex && \
	  apk update && \
    apk upgrade && \
    apk add --no-cache libressl boost libevent libtool libzmq su-exec

RUN addgroup -S bitcoin && adduser -S -D -g bitcoin bitcoin

ENV BITCOIN_ROOT=/opt/blockchain 
ENV BITCOIN_DATA="${BITCOIN_ROOT}/data"

COPY --from=builder --chown=bitcoin:bitcoin ${BITCOIN_ROOT}/bin ${BITCOIN_ROOT}/bin
COPY --from=builder /opt/blockchain/bin/digibyte* /usr/local/bin/

RUN mkdir -p $BITCOIN_ROOT \
  && mkdir -p $BITCOIN_DATA \
  && ln -sfn $BITCOIN_DATA /home/bitcoin/.digibyte \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.digibyte

COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 12024 14022	18332	19332

CMD ["digibyted", "-printtoconsole"]
