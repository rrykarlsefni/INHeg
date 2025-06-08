#!/bin/bash
set -e

cd /home/container

# Warna untuk output terminal
cyan='\033[0;36m'
green='\033[0;32m'
yellow='\033[1;33m'
magenta='\033[0;35m'
bold='\033[1m'
reset='\033[0m'

# Info sistem
now=$(date +"%Y-%m-%d %H:%M:%S")
hostname=$(hostname)
ip_masked="***.***.***.***"   # Masked IP untuk keamanan
cpu=$(grep -m 1 "model name" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ //')
ram=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

# Header
echo -e "${cyan}╭────────────────────────────────────────────╮${reset}"
echo -e "${cyan}│${green}  🚀 InoueHost Container Launcher       ${cyan}│${reset}"
echo -e "${cyan}╰────────────────────────────────────────────╯${reset}"

# Detail Info
echo -e "${yellow}📂 Working Dir   :${reset} /home/container"
echo -e "${yellow}💻 Start Command :${reset} $*"
echo -e "${yellow}🕒 Waktu VPS     :${reset} $now"
echo -e "${yellow}🖥️  Hostname       :${reset} $hostname"
echo -e "${yellow}🌐 IP Publik     :${reset} $ip_masked"
echo -e "${yellow}🧠 RAM Digunakan :${reset} $ram"
echo -e "${yellow}🧮 CPU Info      :${reset} $cpu"
echo

# Animasi loading sederhana
spinner="/-\|"
echo -ne "${magenta}🔄 Menyiapkan container..."
for i in {1..8}; do
  idx=$(( i % 4 ))
  printf "\b${spinner:$idx:1}"
  sleep 0.1
done
echo -e "\b Done!${reset}"

# Footer
echo -e "${green}Terima kasih telah menggunakan InoueHost${reset}"
echo

# Jalankan perintah utama yang diterima script ini
exec "$@"