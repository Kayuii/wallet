FROM ubuntu:xenial

# ARG cores=4
# ENV ecores=$cores
ENV VER=v1.0

RUN apt update \
  && apt install -y --no-install-recommends \
     software-properties-common \
     ca-certificates \
     git curl sudo libusb-1.0-0-dev libicu-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Build source
RUN mkdir -p /opt/blockchain/config \
  && mkdir -p /opt/blockchain/data \
  && ln -s /opt/blockchain/config /root/.dccy_node \
  && cd /opt \
  && git clone --depth 1 --branch master https://github.com/DCCY-Group/DCCY-Deploy.git dccy_node \
  && cd /opt/dccy_node/install \
  && chmod +x ./installer-sakra.sh \
  && sh ./installer-sakra.sh \
  && cd ./dccy \
  && chmod +x node.js \
  && cp -r /opt/dccy_node/install/dccy/* /opt/blockchain/

COPY ./enable_history.js /opt/blockchain/
RUN sed -ie 's/fibos.start()/require(".\/enable_history")(fibos)/g' /opt/blockchain/node.js

# Write default dccy_node.conf (can be overridden on commandline)
RUN echo '{ "config_dir": "/opt/blockchain/config", "data_dir": "/opt/blockchain/data", "core_symbol": "DCCY", "pubkey_prefix": "DCCY", "http_server_address": "0.0.0.0:8870", "p2p_listen_endpoint": "0.0.0.0:9870"}' > /opt/blockchain/config.json

WORKDIR /opt/blockchain/
VOLUME ["/opt/blockchain/config", "/opt/blockchain/data"]

# Port, RPC, Test Port, Test RPC
EXPOSE 8870 9870

CMD ["/opt/blockchain/node.js"]
