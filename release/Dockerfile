FROM debian:9-slim as builder

RUN apt-get update \
  && apt-get install -y curl unzip \
  && rm -rf /var/lib/apt/lists/*

ENV NEO_VER=3.0.0-preview1


RUN curl -vLO https://github.com/neo-project/neo-cli/releases/download/v${NEO_VER}/neo-cli-linux-x64.zip \
    && curl -vLO https://github.com/neo-project/neo-plugins/releases/download/v${NEO_VER}/ApplicationLogs.zip \
    && curl -vLO https://github.com/neo-project/neo-plugins/releases/download/v${NEO_VER}/ImportBlocks.zip \
    && curl -vLO https://github.com/neo-project/neo-plugins/releases/download/v${NEO_VER}/RpcWallet.zip

RUN unzip neo-cli-linux-x64.zip && rm neo-cli-linux-x64.zip \
  && unzip ApplicationLogs.zip -d neo-cli && rm ApplicationLogs.zip \
  && unzip ImportBlocks.zip -d neo-cli && rm ImportBlocks.zip \
  && unzip RpcWallet.zip -d neo-cli && rm RpcWallet.zip

RUN sed -i'' 's/"Chain": .*/"Chain": "Chain",/' ./neo-cli/*.json \
  && sed -i'' 's/"ApplicationLogs_{0}"/"ApplicationLogs"/g' ./neo-cli/Plugins/ApplicationLogs/*.json

FROM mcr.microsoft.com/dotnet/core/runtime:3.0 AS Final

RUN apt-get update \
  # && apt-get install -y libleveldb-dev sqlite3 libsqlite3-dev libunwind8-dev unzip \
  && apt-get install -y libleveldb-dev sqlite3 screen unzip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /neo-cli
COPY  --from=builder /neo-cli .

EXPOSE 10332 20332

ENTRYPOINT ["screen","-DmS","node","dotnet","neo-cli.dll","-r"]
# CMD ["/usr/bin/dotnet", "neo-cli.dll", "/rpc"]
