FROM ghcr.io/parkervcp/yolks:nodejs_24

USER root

# Update dan install dependencies tambahan jika perlu
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

# Pastikan user 'container' ada supaya container aman jalan
RUN id -u container 2>/dev/null || useradd -m container

USER container
WORKDIR /home/container

# Install dependencies dari package.json saat container start
RUN if [ -f package.json ]; then npm install; fi

# Jalankan perintah npm start
CMD ["npm", "start"]