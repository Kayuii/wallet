FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends apt-transport-https ca-certificates wget gnupg gosu \
	&& rm -rf /var/lib/apt/lists/*

RUN wget -q -O - "https://repos.ripple.com/repos/api/gpg/key/public" | \
  apt-key add - \
  && apt-key finger \
  && echo "deb https://repos.ripple.com/repos/rippled-deb bionic stable" | \
    tee -a /etc/apt/sources.list.d/ripple.list 

RUN apt -y update \
  && apt -y install rippled 

# create data directory
ENV BITCOIN_DATA /opt/blockchain/data
RUN mkdir -p "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.ripple \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.ripple
VOLUME /opt/blockchain/data

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 51235 5005 5006 15005 15006
CMD ["rippled"]