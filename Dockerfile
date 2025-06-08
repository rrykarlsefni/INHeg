#tolong jangan di ambil, punya InoueHost:)
FROM ghcr.io/parkervcp/yolks:nodejs_24

USER root

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Jakarta \
    GOPATH=/go \
    PATH=$PATH:/usr/local/go/bin:$GOPATH/bin \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Install OS packages
RUN set -eux; \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    python3 python3-pip python-is-python3 \
    php php-cli php-pear php-dev \
    php-curl php-mbstring php-xml php-gd php-zip php-bcmath \
    php-json php-mysql php-sqlite3 php-readline php-tokenizer php-dom php-opcache \
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
    chromium \
    && curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get update && apt-get install -y speedtest && \
    printf '%s\n' '#!/bin/bash' 'exec /usr/bin/speedtest --accept-license --accept-gdpr "$@"' > /usr/local/bin/speedtest && \
    chmod +x /usr/local/bin/speedtest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# COPY Library lists
COPY handle/pyLib.txt /tmp/pyLib.txt
COPY handle/phpLib.txt /tmp/phpLib.txt
COPY handle/cLib.txt /tmp/cLib.txt
COPY handle/goLib.txt /tmp/goLib.txt

# Install Python Libraries
RUN python3 -m pip install --upgrade pip setuptools wheel --break-system-packages && \
    while IFS= read -r lib || [ -n "$lib" ]; do \
        echo "Installing Python: $lib" && \
        pip install --no-cache-dir "$lib" --break-system-packages || echo "Failed Python: $lib"; \
    done < /tmp/pyLib.txt && rm /tmp/pyLib.txt

# Install PHP Extensions via PECL
RUN while IFS= read -r lib || [ -n "$lib" ]; do \
        echo "Installing PHP PECL: $lib" && \
        yes '' | pecl install "$lib" || echo "Failed PHP: $lib"; \
    done < /tmp/phpLib.txt && rm /tmp/phpLib.txt

# Install C/C++ Development Libraries
RUN while IFS= read -r lib || [ -n "$lib" ]; do \
        echo "Installing C/C++ Dev: $lib" && \
        apt-get install -y --no-install-recommends "$lib" || echo "Failed C/C++: $lib"; \
    done < /tmp/cLib.txt && rm /tmp/cLib.txt

# Install Go Packages
RUN go env -w GO111MODULE=on && \
    mkdir -p "$GOPATH" && \
    while IFS= read -r lib || [ -n "$lib" ]; do \
        echo "Installing Go: $lib" && \
        go install "$lib@latest" || echo "Failed Go: $lib"; \
    done < /tmp/goLib.txt && rm /tmp/goLib.txt

# Enable Corepack and install NodeJS Global Tools
RUN corepack enable && \
    npm install -g \
    chalk@4 \
    fast-cli@2.1.0 \
    pm2 \
    pnpm \
    puppeteer && \
    chmod -R 755 /usr/local/lib/node_modules/fast-cli/node_modules/puppeteer/.local-chromium || true

# Set container user & working dir
USER container
WORKDIR /home/container