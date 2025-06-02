FROM ghcr.io/parkervcp/yolks:nodejs_24

USER root

# Update & install dependencies
RUN set -eux; \
    apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ffmpeg \
    python3 python3-pip \
    php \
    gcc g++ clang make \
    build-essential \
    mono-complete \
    speedtest-cli \
    neofetch \
    procps \
    curl \
    wget \
    unzip \
    htop \
    nano \
    git \
    lsof \
    dnsutils \
    net-tools \
    iputils-ping \
    libtool \
    libtool-bin \
    || true

# Install npm packages (chalk@4 + tesspeed)
RUN set -eux; \
    npm install -g chalk@4; \
    if ! command -v tesspeed >/dev/null 2>&1; then \
        npm install -g tesspeed; \
    fi

# Bersih-bersih
RUN set -eux; \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Kembali ke user non-root
USER container
WORKDIR /home/container