FROM ghcr.io/parkervcp/yolks:nodejs_24

RUN apt update && apt install -y \
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