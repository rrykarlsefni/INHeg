#tolong jangan di ambil:)

FROM ghcr.io/parkervcp/yolks:nodejs_24

USER root

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Jakarta

RUN set -eux; \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    python3 python3-pip \
    php \
    gcc g++ clang make build-essential \
    golang \
    mono-complete \
    neofetch \
    procps \
    curl wget unzip nano git lsof dnsutils net-tools iputils-ping \
    libtool libtool-bin \
    zsh fish jq \
    iproute2 \
    ca-certificates tzdata \
    libsm6 libxext6 libxrender-dev libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxdamage1 libxrandr2 libgbm1 libasound2 libpangocairo-1.0-0 \
    tesseract-ocr imagemagick \
    python-is-python3 && \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get update && apt-get install -y speedtest && \
    printf '%s\n' '#!/bin/bash' 'exec /usr/bin/speedtest --accept-license --accept-gdpr "$@"' > /usr/local/bin/speedtest && \
    chmod +x /usr/local/bin/speedtest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY handle/pyLib.txt /tmp/pyLib.txt

RUN python3 -m pip install --upgrade pip setuptools wheel --break-system-packages && \
    while IFS= read -r lib || [ -n "$lib" ]; do \
        echo "Installing $lib..." && \
        pip install --no-cache-dir "$lib" --break-system-packages || echo "Failed to install $lib, skipping..."; \
    done < /tmp/pyLib.txt && \
    rm /tmp/pyLib.txt

RUN npm install -g chalk@4 fast-cli@2.1.0 pm2 pnpm puppeteer && \
    chmod -R 755 /usr/local/lib/node_modules/fast-cli/node_modules/puppeteer/.local-chromium

USER container
WORKDIR /home/container