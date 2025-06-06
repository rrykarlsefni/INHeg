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
    printf '%s\n' '#!/bin/bash' 'exec /usr/bin/speedtest --accept-license --accept-gdpr "$@"' > /usr/local/bin/speedtest && \
    chmod +x /usr/local/bin/speedtest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY handle/pyLib.txt /tmp/pyLib.txt

RUN pip install --no-cache-dir -r /tmp/pyLib.txt && rm /tmp/pyLib.txt

RUN npm install -g chalk@4 fast-cli

USER container
WORKDIR /home/container