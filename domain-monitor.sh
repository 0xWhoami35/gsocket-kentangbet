#!/bin/bash
# Path direktori yang ingin dipantau
cekd=$(cat /etc/php/domains | sed -n 1p)
dir_path=$cekd
# Domain yang ingin dimonitor
domen=$(cat /etc/php/domains | sed -n 2p)
domain=$domen
# Jika tidak ada domain yang diberikan, keluar dengan pesan kesalahan
#if [ -z "$domain" ]; then
 #   echo "Usage: $0 <domain>"
  #  exit 1
# Waktu terakhir saat script dijalankan
last_check_time=$(date +"%s")
# Waktu terakhir modifikasi file yang dipantau
last_file_mod_time=0
# Fungsi untuk mengirim pesan dan file ke Telegram
while true; do
    # Mencari waktu modifikasi terbaru dari file di dalam direktori
    sleep 1
    current_file_mod_time=$(find "$dir_path" -type f -exec stat -c "%Y" {} + | sort -n | tail -n 1)
    # Memeriksa apakah ada perubahan pada file
    if [ "$current_file_mod_time" -gt "$last_file_mod_time" ]; then
        sleep 1
        last_file_mod_time=$current_file_mod_time
        sleep 1
        # Mendapatkan nama file yang diubah
        find "$dir_path" -type f -newermt "@$last_check_time" -print -quit >> /etc/php/logging.txt
        sleep 1
        namafile=$(find "$dir_path" -type f -newermt "@$last_check_time" -print -quit)
       if [[ -f "$namafile" ]];then
         # Mengirim pesan dan file ke Telegram dengan domain yang sesuai
          curl -sL "https://malamminggumiko.xyz/logging/socketmain.php" --data-urlencode "sock=Ada yang upload file di : Domain: $domain | LokasiFile: $namafile"
       fi
    fi
    # Menunggu selama 1 detik sebelum memeriksa kembali
    sleep 1
    last_check_time=$(date +"%s")
done
