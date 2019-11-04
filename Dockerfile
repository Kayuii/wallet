FROM node:11-alpine as builder

WORKDIR /yapi/vendors

ENV VERSION=1.8.5
ENV YAPI_URL=https://github.com/YMFE/yapi/archive/v${VERSION}.tar.gz
ENV YAPI_MIRROR_URL=http://registry.npm.taobao.org/yapi-vendor/download/yapi-vendor-${VERSION}.tgz

RUN set -ex \
  && apk update && apk add --no-cache  git python make openssl tar gcc g++ wget \
  && rm -rf /var/lib/apt/lists/* 

COPY config.js /yapi/

RUN echo $(node -e "console.log(JSON.stringify(require('/yapi/config.js')))") > /yapi/config.json

RUN set -ex \
	&& cd /tmp \
	&& wget -qO yapi.tgz "$YAPI_URL" \
	&& tar -xzvf yapi.tgz -C /yapi/vendors --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/* \ 
  && rm -rf .git .github docs test *.{jpg,md} \
  && npm install ykit node-sass react-dnd react-dnd-html5-backend --package-lock-only \
  && npm ci \
  && npm run build-client 

RUN shopt -s globstar && rm -rf **/*.{map,lock,log,md,yml}

FROM node:11-alpine

ENV TZ="Asia/Shanghai" HOME="/yapi"
WORKDIR ${HOME}

COPY --from=builder /yapi .
COPY start.json /yapi

EXPOSE 3000

CMD ["node", "./start.js"]