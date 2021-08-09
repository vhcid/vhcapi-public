#!/bin/bash

######################################
#               VHC VDT              #
#         VHC DEVELOPING TEAM        #
######################################

prefix="VHC DNS Security" #Silahkan Diganti kalo butuh :)
auth_email="email@cloudflare.mu" #Email Yang Kamu Registrasikan Untuk Panel Cloudflare mu!
auth_method="token" #gausah diganti ler ini bawaan!
auth_key="00000000000000000000000000000000000" #auth key bisa di dapat dengan cara ke dashboard => API => Get Your API token => API Tokens => Api keys => Global API Key => Views
zone_identifier="0000000000000000000000000000000" #Zone ID bisa di dapatkan di panel cloudflare mu di area API : Contoh Zone ID => 123d56a89f123e5678901b34567890a2
record_name="contoh.cloudflare.mu" #record yang kamu gunakan contoh : A Record : contoh.cloudflare.mu to 8.8.8.8
proxy="false" #jadikan true jika menyalakan cloudflare proxy!

ip=$(curl -s https://api.ipify.org || curl -s https://ipv4.icanhazip.com/)

if [ "${ip}" == "" ]; then
  logger "[$prefix] Tidak Menemukan Public IP!"
  exit 1
fi

if [ "${auth_method}" == "global" ]; then
  auth_header="X-Auth-Key:"
else
  auth_header="Authorization: Bearer"
fi

logger "[$prefix] Pemeriksaan Dimulai!"
record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name" -H "X-Auth-Email: $auth_email" -H "$auth_header $auth_key" -H "Content-Type: application/json")

if [[ $record == *"\"count\":0"* ]]; then
  logger "[$prefix] Record Tidak Ditemukan! Mungkin Bisa Menambahkanya ?(${ip} for ${record_name})"
  exit 1
fi

old_ip=$(echo "$record" | grep -Po '(?<="content":")[^"]*' | head -1)
# Compare if they're the same
if [[ $ip == $old_ip ]]; then
  logger "[$prefix]: IP ($ip) Untuk ${record_name} Tidak Berubah!."
  exit 0
fi

update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                     -H "X-Auth-Email: $auth_email" \
                     -H "$auth_header $auth_key" \
                     -H "Content-Type: application/json" \
              --data "{\"id\":\"$zone_identifier\",\"type\":\"A\",\"proxied\":${proxy},\"name\":\"$record_name\",\"content\":\"$ip\"}")
case "$update" in
  *"\"success\":false"*)
  logger "[$prefix] $ip $record_name DDNS gagal untuk $record_identifier ($ip). Hasil Dumpling:\n$update"
  exit 1;;
  *)
  logger "[$prefix] $ip $record_name DDNS Diperbarui!"
  exit 0;;
esac
