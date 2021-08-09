#!/bin/bash
######################################
#               VHC VDT              #
#         VHC DEVELOPING TEAM        #
######################################

SCRIPT_VER="1.0"

if [[ $EUID -ne 0 ]]; then
  echo "* Script Ini Hanya Boleh Distart Dengan Akses ROOT" 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl dibutuhkan untuk installasi di VHCLIB."
  exit 1
fi
output() {
  echo -e "* ${1}"
}

error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

done=false

output "vhclib@$SCRIPT_VER"
output
output "Copyright (c) VHC Technology 2020 - 2021 <support@vhcid.tech>"
output "https://github.com/vhcid/vhclib"
output
output "Join Our Discord : https://discord.gg/G6baeCcHk2"
output "Join Our Minecraft Server : mc.vhcid.tech"
output "Script Ini Tidak Berkerja sama dengan pihak manapun!"

output

dns-updater(){
  mkdir -p /vhctech
  curl -L -o /vhctech/other https://image.vhcid.tech/$SCRIPT_VER/other/dns-update.sh
  chmod u+x /vhctech/other
  nano /vhctech/other/dns-update.sh
}

while [ "$done" == false ]; do
  options=(
    "Script For Auto Change DNS!"
  )

  actions=(
    "dns-updater"
  )

  output "Apa Yang Ingin Kamu Lakukan hari ini ?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]}-1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i=0;i<=${#actions[@]}-1;i+=1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done
