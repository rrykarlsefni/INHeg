# Jangan diambil, punya InoueHost! :)
FROM ghcr.io/parkervcp/yolks:nodejs_24

USER root

ENV TZ=Asia/Jakarta \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    GOPATH=/go \
    PNPM_HOME=/usr/local/pnpm \
    PATH=$PATH:/usr/local/go/bin:$GOPATH/bin:$PNPM_HOME/bin \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false

# Install base dependencies & tools
RUN set -eux; \
    apt-get update && apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
        curl tar gzip unzip ca-certificates tzdata \
        ffmpeg \
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
        tesseract-ocr imagemagick chromium; \
    # speedtest-cli install
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash; \
    apt-get update && apt-get install -y speedtest; \
    printf '#!/bin/bash\nexec /usr/bin/speedtest --accept-license --accept-gdpr "$@"\n' > /usr/local/bin/speedtest; \
    chmod +x /usr/local/bin/speedtest; \
    apt-get clean; rm -rf /var/lib/apt/lists/*

# Copy dependency lists (biarkan ada)
COPY handle/pyLib.txt /tmp/pyLib.txt
COPY handle/phpLib.txt /tmp/phpLib.txt
COPY handle/cLib.txt /tmp/cLib.txt
COPY handle/goLib.txt /tmp/goLib.txt

# Python packages install
RUN set -eux; \
    python3 -m pip install --upgrade pip setuptools wheel --break-system-packages; \
    if [ -s /tmp/pyLib.txt ]; then \
      xargs -a /tmp/pyLib.txt -r -I {} pip install --no-cache-dir {} --break-system-packages; \
    fi; \
    rm -f /tmp/pyLib.txt

# PHP PECL extensions install
RUN set -eux; \
    if [ -s /tmp/phpLib.txt ]; then \
      xargs -a /tmp/phpLib.txt -r -I {} sh -c 'yes "" | pecl install {} || echo "Fail PHP extension: {}"'; \
    fi; \
    rm -f /tmp/phpLib.txt

# C dependencies install
RUN set -eux; \
    if [ -s /tmp/cLib.txt ]; then \
      xargs -a /tmp/cLib.txt -r -I {} apt-get install -y --no-install-recommends {}; \
    fi; \
    rm -f /tmp/cLib.txt

# Go tools install
RUN set -eux; \
    go env -w GO111MODULE=on; \
    mkdir -p "$GOPATH"; \
    if [ -s /tmp/goLib.txt ]; then \
      xargs -a /tmp/goLib.txt -r -I {} go install {}@latest; \
    fi; \
    rm -f /tmp/goLib.txt

# Install pnpm 10.11.1 manual
RUN set -eux; \
    mkdir -p "$PNPM_HOME"; \
    curl -L -o /tmp/pnpm.tgz https://registry.npmjs.org/pnpm/-/pnpm-10.11.1.tgz; \
    tar -xzf /tmp/pnpm.tgz -C "$PNPM_HOME" --strip-components=1; \
    ln -sf "$PNPM_HOME/bin/pnpm" /usr/local/bin/pnpm; \
    chmod +x "$PNPM_HOME/bin/pnpm"; \
    rm /tmp/pnpm.tgz; \
    ls -l /usr/local/bin/pnpm; \
    /usr/local/bin/pnpm --version

# Install global npm tools: pm2, yarn, puppeteer, chalk, fast-cli
RUN set -eux; \
    npm install -g pm2 yarn chalk@4 fast-cli@2.1.0 puppeteer; \
    npx puppeteer install; \
    chmod -R 755 /usr/local/lib/node_modules/puppeteer/.local-chromium || true

# Copy InouePoint.sh dan beri permission executable
COPY InouePoint.sh /usr/local/bin/InouePoint.sh
RUN chmod +x /usr/local/bin/InouePoint.sh

USER container
WORKDIR /home/container

ENTRYPOINT ["/usr/local/bin/InouePoint.sh"]
CMD ["pnpm", "start"]