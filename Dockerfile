FROM ghcr.io/parkervcp/yolks:nodejs_24

USER root

RUN set -eux; \
    apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ffmpeg \
    python3 python3-pip \
    php \
    gcc g++ clang make build-essential \
    golang \
    mono-complete \
    neofetch \
    procps \
    curl wget unzip htop nano git lsof dnsutils net-tools iputils-ping libtool libtool-bin \
    zsh fish jq && \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get update && apt-get install -y speedtest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN npm install -g chalk@4 fast-cli

USER container
WORKDIR /home/container