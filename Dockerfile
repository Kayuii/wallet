# build via docker:
# docker build --build-arg cores=8 -t blocknetdx/eos:latest .
FROM ubuntu:18.04

ARG cores=2
ENV ecores=$cores

# install dependencies
RUN apt update \
    && apt install -y \
      make bzip2 automake libbz2-dev libssl-dev doxygen graphviz libgmp3-dev \
      autotools-dev libicu-dev python2.7 python2.7-dev python3 python3-dev \
      autoconf libtool curl zlib1g-dev sudo ruby libusb-1.0-0-dev \
      libcurl4-gnutls-dev pkg-config patch vim-common jq wget git cmake \
&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# clone EOSIO repository
RUN git clone --depth 1 --branch v2.0.5 --recursive https://github.com/EOSIO/eos.git /root/eosio/eos \
      && cd /root/eosio/eos \
      && git submodule update --init --recursive \
      && cd /root/eosio/eos/scripts 

# build for hub.docker.com 
# system must have 7 or more Gigabytes of physical memory installed
# fix to remove limit
RUN cd /root/eosio/eos/scripts \
  && grep -rn "Your system must have" . |cut -d ':' -f 1 |sort |uniq |xargs sed -i "/Your system must have/d" 

# build EOSIO
RUN JOBS=$ecores /root/eosio/eos/scripts/eosio_build.sh -y -P

# install EOSIO
RUN /root/eosio/eos/scripts/eosio_install.sh -y \
      && cd /root/eosio/eos/build && make clean \
      && mkdir -p /root/.local/share/eosio/nodeos/config

RUN cd /root/.local/share/eosio/nodeos/config \
        && echo '{                                                              \n\
  "initial_timestamp": "2018-06-08T08:08:08.888",                               \n\
  "initial_key": "EOS7EarnUhcyYqmdnPon8rm7mBCTnBoot6o7fE2WzjvEX2TdggbL3",       \n\
  "initial_configuration": {                                                    \n\
    "max_block_net_usage": 1048576,                                             \n\
    "target_block_net_usage_pct": 1000,                                         \n\
    "max_transaction_net_usage": 524288,                                        \n\
    "base_per_transaction_net_usage": 12,                                       \n\
    "net_usage_leeway": 500,                                                    \n\
    "context_free_discount_net_usage_num": 20,                                  \n\
    "context_free_discount_net_usage_den": 100,                                 \n\
    "max_block_cpu_usage": 200000,                                              \n\
    "target_block_cpu_usage_pct": 1000,                                         \n\
    "max_transaction_cpu_usage": 150000,                                        \n\
    "min_transaction_cpu_usage": 100,                                           \n\
    "max_transaction_lifetime": 3600,                                           \n\
    "deferred_trx_expiration_window": 600,                                      \n\
    "max_transaction_delay": 3888000,                                           \n\
    "max_inline_action_size": 4096,                                             \n\
    "max_inline_action_depth": 4,                                               \n\
    "max_authority_depth": 6                                                    \n\
  }                                                                             \n\
}' > genesis.json

RUN cd /root/.local/share/eosio/nodeos/config \
  && echo 'plugin = eosio::net_plugin                            \n\
plugin = eosio::net_api_plugin                                   \n\
plugin = eosio::chain_plugin                                     \n\
plugin = eosio::chain_api_plugin                                 \n\
plugin = eosio::http_plugin                                      \n\
plugin = eosio::db_size_api_plugin                               \n\
plugin = eosio::state_history_plugin                             \n\
chain-state-db-size-mb = 65536                                   \n\
state-history-endpoint = 0.0.0.0:8080                            \n\
http-server-address = 0.0.0.0:8888                               \n\
http-validate-host = false                                       \n\
max-clients = 50                                                 \n\
trace-history = true                                             \n\
chain-state-history = true                                       \n\
wasm-runtime = eos-vm-jit                                        \n\
eos-vm-oc-enable = true                                          \n\
p2p-peer-address = peer.main.alohaeos.com:9876                   \n\
p2p-peer-address = p2p.eossweden.org:9876                        \n\
p2p-peer-address = seed1.genereos.io:9876                        \n\
p2p-peer-address = p2p.sheos.org:5556                            \n\
p2p-peer-address = eos.unlimitedeos.com:15555                    \n\
p2p-peer-address = eos.okpool.top:9876                           \n\
p2p-peer-address = peer1.eosphere.io:9876                        \n\
p2p-peer-address = node1.eosnewyork.io:6987                      \n\
p2p-peer-address = p2p.validatoreos.xyz:9800                     \n\
p2p-peer-address = node1.zbeos.com:9876                          \n\
p2p-peer-address = p2p.eoscafeblock.com:9000                     \n\
p2p-peer-address = peer.eos-mainnet.eosblocksmith.io:5010        \n\
p2p-peer-address = api.eosvenezuela.io:9876                      \n\
p2p-peer-address = p2p-emlg.eosnairobi.io:9076                   \n\
p2p-peer-address = bp.eosbeijing.one:8080                        \n\
p2p-peer-address = api3.tokenika.io:9876                         \n\
p2p-peer-address = boot.eostitan.com:9876                        \n\
p2p-peer-address = peer2.eoshuobipool.com:18181                  \n\
p2p-peer-address = p2p.eosdetroit.io:3018                        \n\
p2p-peer-address = seed.eoscleaner.com:9876                      \n\
p2p-peer-address = epeer3.nodeone.io:8980                        \n\
p2p-peer-address = p2p.stargalaxy.xyz:9876                       \n\
p2p-peer-address = peering1.mainnet.eosasia.one:80               \n\
p2p-peer-address = p2p-eos.whaleex.com:9876                      \n\
p2p-peer-address = peer1.eoshuobipool.com:18181                  \n\
p2p-peer-address = bp.cryptolions.io:9876                        \n\
p2p-peer-address = p2p.eosargentina.io:5222                      \n\
p2p-peer-address = p2p.eos42.io:9882                             \n\
p2p-peer-address = peering.mainnet.eoscanada.com:9876            \n\
p2p-peer-address = p2p.meet.one:9876                             \n\
p2p-peer-address = p2p.athenbp.club:9800                         \n\
p2p-peer-address = br.eosrio.io:9876                             \n\
p2p-peer-address = eos-mainnet-peer.ecoboost.app:80              \n\
p2p-peer-address = p2p.eoseoul.io:9876                           \n\
p2p-peer-address = p2p.newdex.one:9876                           \n\
p2p-peer-address = node1.eoscannon.io:59876                      \n\
p2p-peer-address = eosbp-0.atticlab.net:9876                     \n\
p2p-peer-address = seed.greymass.com:9876                        \n\
p2p-peer-address = peer.eosio.sg:80                              \n\
p2p-peer-address = node2.zbeos.com:9876                          \n\
p2p-peer-address = publicnode.cypherglass.com:9876               \n\
p2p-peer-address = eos-bp.inbex.pro:9876                         \n\
p2p-peer-address = p2p.eosio.cr:9876                             \n\
p2p-peer-address = p2p.eosflare.io:9876                          \n\
p2p-peer-address = epeer1.nodeone.io:8970                        \n\
p2p-peer-address = pubnode.eosrapid.com:9876                     \n\
p2p-peer-address = fullnode.eoslaomao.com:443                    \n\
p2p-peer-address = mainnet.eoslaomao.com:443                     \n\
p2p-peer-address = mainnet.eosamsterdam.net:9876                 \n\
p2p-peer-address = peer1.mainnet.helloeos.com.cn:80              \n\
p2p-peer-address = node869-mainnet.eosauthority.com:9393         \n\
p2p-peer-address = mainnet.get-scatter.com:9876                  \n\
p2p-peer-address = bp.antpool.com:443                            \n\
p2p-peer-address = 47.75.70.208:9376                             \n\
p2p-peer-address = fn001.eossv.org:445                           \n\
p2p-peer-address = mainnet.eosarabia.net:3571                    \n\
actor-blacklist=newdexmobapp                                     \n\
actor-blacklist=ftsqfgjoscma                                     \n\
actor-blacklist=hpbcc4k42nxy                                     \n\
actor-blacklist=3qyty1khhkhv                                     \n\
actor-blacklist=xzr2fbvxwtgt                                     \n\
actor-blacklist=myqdqdj4qbge                                     \n\
actor-blacklist=shprzailrazt                                     \n\
actor-blacklist=qkwrmqowelyu                                     \n\
actor-blacklist=lhjuy3gdkpq4                                     \n\
actor-blacklist=lmfsopxpr324                                     \n\
actor-blacklist=lcxunh51a1gt                                     \n\
actor-blacklist=geydddsfkk5e                                     \n\
actor-blacklist=pnsdiia1pcuy                                     \n\
actor-blacklist=kwmvzswquqpb                                     \n\
actor-blacklist=guagddoefdqu                                     \n\
actor-blacklist=gizdkmjvhege                                     \n\
actor-blacklist=refundwallet                                     \n\
actor-blacklist=jhonnywalker                                     \n\
actor-blacklist=alibabaioeos                                     \n\
actor-blacklist=whitegroupes                                     \n\
actor-blacklist=24cryptoshop                                     \n\
actor-blacklist=minedtradeos                                     \n\
actor-blacklist=guzdanrugene                                     \n\
actor-blacklist=earthsop1sys                                     \n\
actor-blacklist=gyzdmmjsgige                                     \n\
actor-blacklist=gizdcnjyg4ge                                     \n\
actor-blacklist=g4ytenbxgqge                                     \n\
actor-blacklist=jinwen121212                                     \n\
actor-blacklist=ha4tomztgage                                     \n\
actor-blacklist=my1steosobag                                     \n\
actor-blacklist=iloveyouplay                                     \n\
actor-blacklist=eoschinaeos2                                     \n\
actor-blacklist=eosholderkev                                     \n\
actor-blacklist=dreams12true                                     \n\
actor-blacklist=imarichman55                                     \n\
actor-blacklist=gm3dcnqgenes                                     \n\
actor-blacklist=gm34qnqrepqt                                     \n\
actor-blacklist=gt3ftnqrrpqp                                     \n\
actor-blacklist=gtwvtqptrpqp                                     \n\
actor-blacklist=gm31qndrspqr                                     \n\
actor-blacklist=lxl2atucpyos                                     \n\
actor-blacklist=huobldeposit                                     \n\
actor-blacklist=guytqmbuhege                                     \n\
actor-blacklist=wangfuhuahua                                     \n\
actor-blacklist=eosfomoplay1                                     \n\
actor-blacklist=craigspys211                                     \n\
actor-blacklist=craigspys211                                     \n\
actor-blacklist=neverlandwal                                     \n\
actor-blacklist=tseol5n52kmo                                     \n\
actor-blacklist=potus1111111                                     \n\
actor-blacklist=gu2teobyg4ge                                     \n\
actor-blacklist=gq4demryhage                                     \n\
actor-blacklist=q4dfv32fxfkx                                     \n\
actor-blacklist=ktl2qk5h4bor                                     \n\
actor-blacklist=haydqnbtgene                                     \n\
actor-blacklist=ktl2qk5h4bor                                     \n\
actor-blacklist=haydqnbtgene                                     \n\
actor-blacklist=g44dsojygyge                                     \n\
actor-blacklist=guzdonzugmge                                     \n\
actor-blacklist=ha4doojzgyge                                     \n\
actor-blacklist=gu4damztgyge                                     \n\
actor-blacklist=haytanjtgige                                     \n\
actor-blacklist=exchangegdax                                     \n\
actor-blacklist=cmod44jlp14k                                     \n\
actor-blacklist=2fxfvlvkil4e                                     \n\
actor-blacklist=yxbdknr3hcxt                                     \n\
actor-blacklist=yqjltendhyjp                                     \n\
actor-blacklist=pm241porzybu                                     \n\
actor-blacklist=xkc2gnxfiswe                                     \n\
actor-blacklist=ic433gs42nky                                     \n\
actor-blacklist=fueaji11lhzg                                     \n\
actor-blacklist=w1ewnn4xufob                                     \n\
actor-blacklist=ugunxsrux2a3                                     \n\
actor-blacklist=gz3q24tq3r21                                     \n\
actor-blacklist=u5rlltjtjoeo                                     \n\
actor-blacklist=k5thoceysinj                                     \n\
actor-blacklist=ebhck31fnxbi                                     \n\
actor-blacklist=pvxbvdkces1x                                     \n\
actor-blacklist=oucjrjjvkrom                                     \n\
actor-blacklist=blacklistmee                                     \n\
actor-blacklist=ge2dmmrqgene                                     \n\
actor-blacklist=gu2timbsguge                                     \n\
actor-blacklist=ge4tsmzvgege                                     \n\
actor-blacklist=gezdonzygage                                     \n\
actor-blacklist=ha4tkobrgqge                                     \n\
actor-blacklist=gq4dkmzzhege' > config.ini

RUN cd /root/.local/share/eosio/nodeos/config \
  && echo '{                                           \n\
        "includes": [],                                \n\
        "appenders": [{                                \n\
                "name": "consoleout",                  \n\
                "type": "console",                     \n\
                "args": {                              \n\
                        "stream": "std_out",           \n\
                        "level_colors": [{             \n\
                                "level": "debug",      \n\
                                "color": "green"       \n\
                        },{                            \n\
                        "level": "warn",               \n\
                        "color": "brown"               \n\
                        },{                            \n\
                        "level": "error",              \n\
                        "color": "red"                 \n\
                        }                              \n\
                        ]                              \n\
                },                                     \n\
                "enabled": true                        \n\
        },                                             \n\
        {                                              \n\
                "name": "errout",                      \n\
                "type": "console",                     \n\
                "args": {                              \n\
                        "stream": "std_error"          \n\
                },                                     \n\
                "enabled": true                        \n\
        }                                              \n\
        ],                                             \n\
        "loggers": [{                                  \n\
                "name": "default",                     \n\
                "level": "info",                       \n\
                "enabled": true,                       \n\
                "additivity": false,                   \n\
                "appenders": [                         \n\
                        "consoleout"                   \n\
                ]                                      \n\
        },                                             \n\
        {                                              \n\
                "name": "default",                     \n\
                "level": "debug",                      \n\
                "enabled": true,                       \n\
                "additivity": false,                   \n\
                "appenders": [                         \n\
                        "errout"                       \n\
                ]                                      \n\
        }                                              \n\
        ]                                              \n\
}' > logging.json

WORKDIR /root/eosio/2.0/bin/
VOLUME ["/root/.local/share/eosio"]

EXPOSE 8080 8888 9876

CMD ["./nodeos", "--disable-replay-opts", "--genesis-json=/root/.local/share/eosio/nodeos/config/genesis.json"]