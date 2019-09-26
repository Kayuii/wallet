FROM debian:9-slim as builder

RUN apt-get update \
  && apt-get install -y unzip \
  && rm -rf /var/lib/apt/lists/*

RUN cli_latest_tag=`curl -s https://api.github.com/repos/neo-project/neo-cli/releases/latest | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/'` \
    && curl -vLO https://github.com/neo-project/neo-cli/releases/download/$cli_latest_tag/neo-cli-linux-x64.zip \
    && plugin_latest_tag=`curl -s https://api.github.com/repos/neo-project/neo-plugins/releases/latest | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/'` \
    && curl -vLO https://github.com/neo-project/neo-plugins/releases/download/$plugin_latest_tag/ApplicationLogs.zip \
    && curl -vLO https://github.com/neo-project/neo-plugins/releases/download/$plugin_latest_tag/ImportBlocks.zip \
    && curl -vLO https://github.com/neo-project/neo-plugins/releases/download/$plugin_latest_tag/RpcWallet.zip

RUN unzip neo-cli-linux-x64.zip && rm neo-cli-linux-x64.zip \
  && unzip ApplicationLogs.zip -d neo-cli && rm ApplicationLogs.zip \
  && unzip ImportBlocks.zip -d neo-cli && rm ImportBlocks.zip \
  && unzip RpcWallet.zip -d neo-cli && rm RpcWallet.zip

RUN sed -i'' 's/"Chain": .*/"Chain": "Chain",/' *.json \
  && sed -i'' 's/"ApplicationLogs_{0}"/"ApplicationLogs"/g' Plugins/ApplicationLogs/*.json

FROM microsoft/dotnet:runtime

RUN apt-get update \
  # && apt-get install -y libleveldb-dev sqlite3 libsqlite3-dev libunwind8-dev unzip \
  && apt-get install -y libleveldb sqlite3 libsqlite3 libunwind8 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /neo-cli
COPY  --from=Build /neo-cli .

EXPOSE 10332 20332

CMD ["/usr/bin/dotnet", "neo-cli.dll", "/rpc"]
