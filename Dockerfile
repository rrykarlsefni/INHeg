FROM ghcr.io/parkervcp/yolks:nodejs_24

USER root

# === Environment Global ===
ENV TZ=Asia/Jakarta \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false

# === Instalasi Paket Dasar + Chromium + OCR + Tools ===
RUN set -eux; \
    apt-get update && apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
        curl tar gzip unzip ca-certificates tzdata gnupg \
        ffmpeg tesseract-ocr imagemagick \
        python3 python3-pip python-is-python3 \
        php php-cli php-pear php-dev php-curl php-mbstring php-xml php-gd php-zip php-bcmath php-json php-mysql php-sqlite3 php-readline php-tokenizer php-dom php-opcache \
        gcc g++ clang make build-essential \
        golang \
        mono-complete \
        neofetch procps \
        wget nano git lsof dnsutils net-tools iputils-ping \
        libtool libtool-bin \
        zsh fish jq iproute2 \
        libsm6 libxext6 libxrender-dev libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxdamage1 libxrandr2 libgbm1 libasound2 libpangocairo-1.0-0 \
        chromium; \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash; \
    apt-get update && apt-get install -y speedtest; \
    printf '#!/bin/bash\nexec /usr/bin/speedtest --accept-license --accept-gdpr "$@"\n' > /usr/local/bin/speedtest; \
    chmod +x /usr/local/bin/speedtest; \
    apt-get clean; rm -rf /var/lib/apt/lists/*

# === Salin Daftar Library ===
COPY handle/pyLib.txt /tmp/pyLib.txt
COPY handle/phpLib.txt /tmp/phpLib.txt
COPY handle/cLib.txt /tmp/cLib.txt
COPY handle/goLib.txt /tmp/goLib.txt

# === Python: pip install ===
RUN set -eux; \
    python3 -m pip install --upgrade pip setuptools wheel --break-system-packages; \
    if [ -s /tmp/pyLib.txt ]; then \
      xargs -a /tmp/pyLib.txt -r -I {} pip install --no-cache-dir {} --break-system-packages; \
    fi; \
    rm -f /tmp/pyLib.txt

# === PHP: PECL Extensions ===
RUN set -eux; \
    if [ -s /tmp/phpLib.txt ]; then \
      xargs -a /tmp/phpLib.txt -r -I {} sh -c 'yes "" | pecl install {} || echo "Skip PHP ext: {}"'; \
    fi; \
    rm -f /tmp/phpLib.txt

# === C Packages ===
RUN set -eux; \
    if [ -s /tmp/cLib.txt ]; then \
      xargs -a /tmp/cLib.txt -r -I {} apt-get install -y --no-install-recommends {}; \
    fi; \
    rm -f /tmp/cLib.txt

# === Go Tools Install (Fix GOPATH & @latest error) ===
RUN set -eux; \
    export GOPATH=/go; \
    export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin; \
    go env -w GO111MODULE=on; \
    mkdir -p "$GOPATH"; \
    if [ -s /tmp/goLib.txt ]; then \
      while IFS= read -r pkg; do go install "$pkg@latest" || echo "Skip Go tool: $pkg"; done < /tmp/goLib.txt; \
    fi; \
    rm -f /tmp/goLib.txt

# === PNPM Manual Install ===
RUN set -eux; \
    mkdir -p /usr/local/pnpm; \
    curl -L -o /tmp/pnpm.tgz https://registry.npmjs.org/pnpm/-/pnpm-10.11.1.tgz; \
    tar -xzf /tmp/pnpm.tgz -C /usr/local/pnpm --strip-components=1; \
    ln -sf /usr/local/pnpm/bin/pnpm /usr/local/bin/pnpm; \
    chmod +x /usr/local/pnpm/bin/pnpm; \
    rm /tmp/pnpm.tgz; \
    pnpm --version

# === Global NPM Tools (untuk bot WhatsApp) ===
RUN set -eux; \
    npm install -g pm2 yarn chalk@4 fast-cli@2.1.0 puppeteer; \
    npx puppeteer install || true; \
    chmod -R 755 /usr/local/lib/node_modules/puppeteer/.local-chromium || true

# === Tambah Startup Handler ===
COPY InouePoint.sh /usr/local/bin/InouePoint.sh
RUN chmod +x /usr/local/bin/InouePoint.sh

# === Final ===
USER container
WORKDIR /home/container

ENTRYPOINT ["/usr/local/bin/InouePoint.sh"]
CMD ["pnpm", "start"]