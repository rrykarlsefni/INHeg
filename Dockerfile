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
    procps \
    && npm install -g chalk@4 \
    && rm -rf /var/lib/apt/lists/*

# Buat user 'container' hanya kalau belum ada, supaya build tidak error
RUN id -u container 2>/dev/null || useradd -m container

USER container
WORKDIR /home/container

CMD ["sh", "-c", "echo 'InoueHost' && tail -f /dev/null"]