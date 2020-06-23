FROM golang:1.14 as builder

#
# NOTE: The RPC server listens on localhost by default.
#       If you require access to the RPC server,
#       rpclisten should be set to an empty value.
#
# NOTE: When running simnet, you may not want to preserve
#       the data and logs.  This can be achieved by specifying
#       a location outside the default ~/.dcrd.  For example:
#          rpclisten=
#          simnet=1
#          datadir=~/simnet-data
#          logdir=~/simnet-logs
#
# Example testnet instance with RPC server access:
# $ mkdir -p /local/path/dcrd
#
# Place a dcrd.conf into a local directory, i.e. /var/dcrd
# $ mv dcrd.conf /var/dcrd
#
# Verify basic configuration
# $ cat /var/dcrd/dcrd.conf
# rpclisten=
# testnet=1
#
# Build the docker image
# $ docker build -t user/dcrd -f Dockerfile.alpine .
#
# Run the docker image, mapping the testnet dcrd RPC port.
# $ docker run -d --rm -p 127.0.0.1:19109:19109 -v /var/dcrd:/root/.dcrd user/dcrd
#

ENV VER=release-v1.5.1
ENV PROJECTDIR=/opt/blocknet/repo
ENV BASEPREFIX=$PROJECTDIR/depends
ENV HOST=x86_64-pc-linux-gnu

RUN mkdir -p /opt/blocknet \
  && cd /opt/blocknet \
  && git clone --depth 1 --branch $VER https://github.com/decred/dcrd.git repo \
  && git clone --depth 1 --branch master https://github.com/decred/dcrctl.git repo1 

# # Build source
RUN mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.dcrd 
  
RUN cd $PROJECTDIR \
  && CGO_ENABLED=0 GOOS=linux GO111MODULE=on go install . ./cmd/... \
  && cd ../repo1 \
  && CGO_ENABLED=0 GOOS=linux GO111MODULE=on go install

FROM alpine:3.10.1

RUN apk add --no-cache ca-certificates su-exec

COPY --from=builder /go/bin/* /usr/local/bin/

RUN addgroup -S bitcoin && adduser -S -D -g bitcoin bitcoin

ENV BITCOIN_ROOT=/opt/blockchain
ENV BITCOIN_DATA=/opt/blockchain/data

RUN mkdir -p ${BITCOIN_DATA} \
	&& chown -R bitcoin:bitcoin "$BITCOIN_ROOT" \
	&& ln -sfn "$BITCOIN_ROOT" /home/bitcoin/.dcrd \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.dcrd 

COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR ${BITCOIN_ROOT}

ENTRYPOINT ["/entrypoint.sh"]

# Port, RPC, Test Port, Test RPC
EXPOSE 9108 9109 19108 19109

CMD ["dcrd"]
