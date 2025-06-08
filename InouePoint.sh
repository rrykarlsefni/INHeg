#!/bin/bash
set -e

cd /home/container

# Deteksi terminal mendukung warna
if [ -t 1 ]; then
  cyan='\033[0;36m'
  green='\033[0;32m'
  yellow='\033[1;33m'
  magenta='\033[0;35m'
  bold='\033[1m'
  reset='\033[0m'
else
  cyan=''; green=''; yellow=''; magenta=''; bold=''; reset=''
fi

# Info sistem
now=$(date +"%Y-%m-%d %H:%M:%S")
hostname=$(hostname)
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -z "$ip" ] && ip="127.0.0.1"
ip_masked=$(echo "$ip" | sed -E 's/[0-9]+\.[0-9]+\.[0-9]+\.([0-9]+)/***.***.***.\1/')
cpu=$(grep -m 1 "model name" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ //')
cores=$(grep -c ^processor /proc/cpuinfo)
ram=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
uptime_info=$(uptime -p)
boot_time=$(uptime -s)

# Header
echo -e "${cyan}╭────────────────────────────────────────────╮${reset}"
echo -e "${cyan}│${green}  🚀 InoueHost Container Launcher       ${cyan}│${reset}"
echo -e "${cyan}╰────────────────────────────────────────────╯${reset}"

# Detail Info
echo -e "${yellow}📂 Working Dir    :${reset} /home/container"
echo -e "${yellow}💻 Start Command  :${reset} $*"
echo -e "${yellow}🕒 Waktu VPS      :${reset} $now"
echo -e "${yellow}⏱️  Uptime VPS     :${reset} $uptime_info"
echo -e "${yellow}🗓️  Waktu Boot VPS :${reset} $boot_time"
echo -e "${yellow}🖥️  Hostname        :${reset} $hostname"
echo -e "${yellow}🌐 IP Publik      :${reset} $ip_masked"
echo -e "${yellow}🧠 RAM Digunakan  :${reset} $ram"
echo -e "${yellow}🧮 CPU Info       :${reset} $cpu (${cores} core)"
echo

# Animasi spinner
spinner="/-\|"
echo -ne "${magenta}🔄 Menyiapkan container..."
for i in {1..12}; do
  idx=$(( i % 4 ))
  printf "\b${spinner:$idx:1}"
  sleep 0.25
done
echo -e "\b ✅${reset}"

# Footer
echo -e "${green}Terima kasih telah menggunakan InoueHost!${reset}"
echo

# Jalankan perintah asli
if [ -z "$1" ]; then
  echo -e "${yellow}⚠️  Tidak ada perintah startup. Menjalankan default: node .${reset}"
  exec node .
else
  exec "$@"
fi