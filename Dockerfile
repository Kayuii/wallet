# fork from https://github.com/zcoinofficial/zcoin/Dockerfile
# This is a Dockerfile for zcoind.
FROM debian:stretch as builder

ARG cores=1
ENV ecores=$cores
ENV VER=v0.14.0.0

# Install required system packages
RUN apt-get update && apt-get install -y \
    automake \
    bsdmainutils \
    curl \
    g++ \
    libboost-all-dev \
    libevent-dev \
    libssl-dev \
    libtool \
    libzmq3-dev \
    make \
    openjdk-8-jdk \
    pkg-config \
    zlib1g-dev \
    git \
    cmake

# Install Berkeley DB 4.8
RUN curl -L http://download.oracle.com/berkeley-db/db-4.8.30.tar.gz | tar -xz -C /tmp && \
    cd /tmp/db-4.8.30/build_unix && \
    ../dist/configure --enable-cxx --includedir=/usr/include/bdb4.8 --libdir=/usr/lib && \
    make -j${cores} && make install && \
    cd / && rm -rf /tmp/db-4.8.30

# Install minizip from source (unavailable from apt on Ubuntu 14.04)
RUN curl -L https://www.zlib.net/zlib-1.2.11.tar.gz | tar -xz -C /tmp && \
    cd /tmp/zlib-1.2.11/contrib/minizip && \
    autoreconf -fi && \
    ./configure --enable-shared=no --with-pic && \
    make -j${cores} install && \
    cd / && rm -rf /tmp/zlib-1.2.11

# Install zmq from source (outdated version from apt on Ubuntu 14.04)
RUN curl -L https://github.com/zeromq/libzmq/releases/download/v4.3.1/zeromq-4.3.1.tar.gz | tar -xz -C /tmp && \
    cd /tmp/zeromq-4.3.1/ && ./configure --disable-shared --without-libsodium --with-pic && \
    make -j${cores} install && \
    cd / && rm -rf /tmp/zeromq-4.3.1/

# Build Zcoin
# COPY . /tmp/zcoin/
# fix. git clone from zcoin
ENV PROJECTDIR=/opt/blocknet/repo
ENV BASEPREFIX=$PROJECTDIR/depends
ENV HOST=x86_64-pc-linux-gnu

RUN mkdir -p /opt/blocknet \
  && cd /opt/blocknet \
  && git clone --depth 1 --branch $VER https://github.com/zcoinofficial/zcoin.git repo

RUN ls -al /usr/local/ 

RUN cd ${PROJECTDIR} && \
    ./autogen.sh && \
    ./configure --without-gui --prefix=/usr/local && \
    make -j${cores} && \
    make check && \
    strip src/zcoind && \
    strip src/zcoin-tx && \
    strip src/zcoin-cli && \
    make install 

RUN ls -al /usr/local/ \
  && ls -al /usr/local/bin/ \
  && ls -al /usr/local/bin/tor
  
FROM debian:stretch-slim 

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends gosu \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

ENV BITCOIN_DATA=/opt/blockchain/data

COPY --from=builder /usr/local/zcoin* /usr/local/bin/

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.zcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.zcoin

COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR ${BITCOIN_DATA}
VOLUME ["${BITCOIN_DATA}"]

ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 8168 8888 18168 18888

CMD ["zcoind", "-printtoconsole"]
