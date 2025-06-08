#!/bin/bash
set -e

# Path ke folder kerja (bisa disesuaikan)
WORKDIR="/home/container"

cd "$WORKDIR"

echo "[InouePoint.sh] Starting container..."

# Pilih package manager sesuai file lock yang ada
if [ -f pnpm-lock.yaml ]; then
  echo "[InouePoint.sh] Detected pnpm-lock.yaml, menggunakan pnpm"
  INSTALL_CMD="pnpm install"
  START_CMD="pnpm start"
elif [ -f package-lock.json ]; then
  echo "[InouePoint.sh] Detected package-lock.json, menggunakan npm"
  INSTALL_CMD="npm install"
  START_CMD="npm start"
elif [ -f yarn.lock ]; then
  echo "[InouePoint.sh] Detected yarn.lock, menggunakan yarn"
  INSTALL_CMD="yarn install"
  START_CMD="yarn start"
else
  echo "[InouePoint.sh] Tidak menemukan lockfile, menggunakan npm default"
  INSTALL_CMD="npm install"
  START_CMD="npm start"
fi

# Jalankan install dependencies
echo "[InouePoint.sh] Menjalankan: $INSTALL_CMD"
$INSTALL_CMD

# Kalau ada argumen (misal pm2, node, dll), jalankan argumen tsb
if [ "$#" -gt 0 ]; then
  echo "[InouePoint.sh] Menjalankan perintah custom: $*"
  exec "$@"
else
  # Default jalankan start script
  echo "[InouePoint.sh] Menjalankan start script: $START_CMD"
  exec $START_CMD
fi