FROM golang:1.14 as builder

ENV VER=v0.6.4
ENV PROJECTDIR=/opt/blocknet/repo
ENV BASEPREFIX=$PROJECTDIR/depends
ENV HOST=x86_64-pc-linux-gnu

RUN mkdir -p /opt/blocknet \
  && cd /opt/blocknet \
  && git clone --depth 1 --branch v0.6.4 https://github.com/filecoin-project/go-filecoin.git repo 

# # Build source
RUN mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.dcrd 
  
RUN cd $PROJECTDIR \
  && git submodule update --init --recursive \
  && make deps \
  && make 

# FROM alpine:3.10.1

# RUN apk add --no-cache ca-certificates openssl su-exec \
#   && apk upgrade

# COPY --from=builder /go/bin/* /usr/local/bin/

# RUN addgroup -S bitcoin && adduser -S -D -g bitcoin bitcoin

# ENV BITCOIN_ROOT=/opt/blockchain
# ENV BITCOIN_DATA=/opt/blockchain/data

# RUN mkdir -p ${BITCOIN_DATA} \
# 	&& chown -R bitcoin:bitcoin "$BITCOIN_ROOT" \
# 	&& ln -sfn "$BITCOIN_ROOT" /home/bitcoin/.dcrd \
# 	&& chown -h bitcoin:bitcoin /home/bitcoin/.dcrd 

# COPY docker-entrypoint.sh /entrypoint.sh
# COPY wait-for.sh /usr/local/bin/wait-for

# WORKDIR ${BITCOIN_ROOT}

# ENTRYPOINT ["/entrypoint.sh"]

# # Port, RPC, Test Port, Test RPC
# EXPOSE 9108 9109 19108 19109

# CMD ["dcrd"]
