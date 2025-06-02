FROM ghcr.io/parkervcp/yolks:nodejs_24

USER root

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ffmpeg \
    python3 python3-pip \
    php \
    gcc g++ clang make \
    mono-complete \
    speedtest-cli \
    neofetch \
    && npm install -g chalk@4 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m container
USER container
WORKDIR /home/container

CMD ["sh", "-c", "echo 'InoueHost' && tail -f /dev/null"]