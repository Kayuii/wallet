FROM alpine:3.8 as builder

ARG cores=1
ENV ecores=$cores
ENV VER=v6.0.2

RUN apk update && \
    apk upgrade && \
    apk add --no-cache libressl boost libevent libtool libzmq boost-dev libressl-dev libevent-dev zeromq-dev

RUN apk add --no-cache git autoconf automake g++ make file curl wget

RUN curl -L http://download.oracle.com/berkeley-db/db-4.8.30.tar.gz | tar -xz -C /tmp && \
  cd /tmp/db-4.8.30/build_unix && \
  ../dist/configure --enable-cxx --includedir=/usr/include/bdb4.8 --libdir=/usr/lib && \
  make -j$(nproc) && make install && \
  cd / && rm -rf /tmp/db-4.8.30

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
#   && make NO_QT=1 -j$(nproc) && make install 

RUN git config --global http.sslVerify false
  
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
