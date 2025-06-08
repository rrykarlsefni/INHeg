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

# Install dependencies & tools
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
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash; \
    apt-get update && apt-get install -y speedtest || true; \
    printf '#!/bin/bash\nexec /usr/bin/speedtest --accept-license --accept-gdpr "$@"\n' > /usr/local/bin/speedtest; \
    chmod +x /usr/local/bin/speedtest; \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Salin daftar library
COPY handle/pyLib.txt /tmp/pyLib.txt
COPY handle/phpLib.txt /tmp/phpLib.txt
COPY handle/cLib.txt /tmp/cLib.txt
COPY handle/goLib.txt /tmp/goLib.txt

# Python: install package, lanjut walau error
RUN python3 -m pip install --upgrade pip setuptools wheel --break-system-packages; \
    if [ -s /tmp/pyLib.txt ]; then \
      xargs -a /tmp/pyLib.txt -r -I {} sh -c 'pip install --no-cache-dir {} --break-system-packages || echo "Gagal install python lib: {}"'; \
    fi; \
    rm -f /tmp/pyLib.txt

# PHP: install PECL ext, lanjut walau error
RUN if [ -s /tmp/phpLib.txt ]; then \
      xargs -a /tmp/phpLib.txt -r -I {} sh -c 'yes "" | pecl install {} || echo "Gagal install php ext: {}"'; \
    fi; \
    rm -f /tmp/phpLib.txt

# C: install lib via apt, lanjut walau error
RUN if [ -s /tmp/cLib.txt ]; then \
      xargs -a /tmp/cLib.txt -r -I {} sh -c 'apt-get install -y --no-install-recommends {} || echo "Gagal install c lib: {}"'; \
    fi; \
    rm -f /tmp/cLib.txt

# Go: install tools, lanjut walau error
RUN go env -w GO111MODULE=on; \
    mkdir -p "$GOPATH"; \
    if [ -s /tmp/goLib.txt ]; then \
      xargs -a /tmp/goLib.txt -r -I {} sh -c 'go install {}@latest || echo "Gagal install go tool: {}"'; \
    fi; \
    rm -f /tmp/goLib.txt

# Enable pnpm via corepack (lebih stabil)
RUN corepack enable && corepack prepare pnpm@10.11.1 --activate

# Install global npm packages
RUN npm install -g pm2 yarn chalk@4 fast-cli puppeteer; \
    npx puppeteer install || true; \
    chmod -R 755 /usr/local/lib/node_modules/puppeteer/.local-chromium || true

# Salin entrypoint
COPY InouePoint.sh /usr/local/bin/InouePoint.sh
RUN chmod +x /usr/local/bin/InouePoint.sh

USER container
WORKDIR /home/container

ENTRYPOINT ["/usr/local/bin/InouePoint.sh"]
CMD ["pnpm", "start"]