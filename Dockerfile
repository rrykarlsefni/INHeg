# jangan di ambil, punya InoueHost!!!:)
FROM ghcr.io/parkervcp/yolks:nodejs_24

USER root

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Jakarta \
    GOPATH=/go \
    PNPM_HOME=/usr/local/pnpm \
    PATH=$PATH:/usr/local/go/bin:$GOPATH/bin:$PNPM_HOME/bin \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    DEBIAN_FRONTEND=noninteractive

# Install all dependencies
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
        chromium && \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get update && apt-get install -y speedtest && \
    printf '#!/bin/bash\nexec /usr/bin/speedtest --accept-license --accept-gdpr "$@"\n' > /usr/local/bin/speedtest && \
    chmod +x /usr/local/bin/speedtest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy package list
COPY handle/pyLib.txt /tmp/pyLib.txt
COPY handle/phpLib.txt /tmp/phpLib.txt
COPY handle/cLib.txt /tmp/cLib.txt
COPY handle/goLib.txt /tmp/goLib.txt

# Python packages
RUN python3 -m pip install --upgrade pip setuptools wheel --break-system-packages && \
    xargs -a /tmp/pyLib.txt -I {} pip install --no-cache-dir {} --break-system-packages || true && \
    rm /tmp/pyLib.txt

# PHP PECL
RUN xargs -a /tmp/phpLib.txt -I {} sh -c 'yes "" | pecl install {} || echo "Fail PHP: {}"' && rm /tmp/phpLib.txt

# C dependencies
RUN xargs -a /tmp/cLib.txt -I {} apt-get install -y --no-install-recommends {} || true && rm /tmp/cLib.txt

# Golang tools
RUN go env -w GO111MODULE=on && \
    mkdir -p "$GOPATH" && \
    xargs -a /tmp/goLib.txt -I {} go install {}@latest || true && \
    rm /tmp/goLib.txt

# Install pnpm 10.11.1 manual (overwrite jika sudah ada)
RUN mkdir -p $PNPM_HOME && \
    curl -L https://registry.npmjs.org/pnpm/-/pnpm-10.11.1.tgz | tar -xz -C $PNPM_HOME --strip-components=1 && \
    rm -f /usr/local/bin/pnpm && \
    ln -s $PNPM_HOME/bin/pnpm /usr/local/bin/pnpm

# Puppeteer & global tools
RUN npm install -g chalk@4 fast-cli@2.1.0 pm2 puppeteer && \
    npx puppeteer install && \
    chmod -R 755 /usr/local/lib/node_modules/puppeteer/.local-chromium || true

USER container
WORKDIR /home/container