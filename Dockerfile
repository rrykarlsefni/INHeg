# Base image dari yolks Node.js 24
FROM ghcr.io/parkervcp/yolks:nodejs_24

# Install tools dan dependencies tambahan
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

# Tambahkan user non-root agar aman untuk panel
RUN useradd -m container

# Jalankan sebagai user container
USER container

# Set direktori kerja
WORKDIR /home/container

# Perintah default saat container dijalankan
CMD ["sh", "-c", "echo 'InoueHost' && tail -f /dev/null"]