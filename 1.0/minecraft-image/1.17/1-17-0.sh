#!/bin/bash
# Paper 1.17 (Custom SMP) Installation Script
#
# Server Files: /mnt/server
PROJECT=paper #Do Not Change This For Any Reason
VHAPI_VERSION=1.0 #Change This If Some Update At data bases

apt update
apt install -y curl jq
apt-get install unzip

if [ -n "${DL_PATH}" ]; then
	echo -e "Menggunakan Download Url: ${DL_PATH}"
	DOWNLOAD_URL=`eval echo $(echo ${DL_PATH} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
else
	VER_EXISTS=`curl -s https://papermc.io/api/v2/projects/${PROJECT} | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | contains($VERSION)' | grep true`
	LATEST_VERSION=`curl -s https://papermc.io/api/v2/projects/${PROJECT} | jq -r '.versions' | jq -r '.[-1]'`

	if [ "${VER_EXISTS}" == "true" ]; then
		echo -e "Versi Sudah Valid!. Menggunakan Versi Paper ${MINECRAFT_VERSION} + versi VHAPI : ${VHAPI_VERSION}"
	else
		echo -e "Using the latest ${PROJECT} version"
		MINECRAFT_VERSION=${LATEST_VERSION}
	fi

	BUILD_EXISTS=`curl -s https://papermc.io/api/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION} | jq -r --arg BUILD ${BUILD_NUMBER} '.builds[] | tostring | contains($BUILD)' | grep true`
	LATEST_BUILD=`curl -s https://papermc.io/api/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION} | jq -r '.builds' | jq -r '.[-1]'`

	if [ "${BUILD_EXISTS}" == "true" ]; then
		echo -e "Build Sudah Valid Untuk Versi ${MINECRAFT_VERSION}. Menggunakan build ${BUILD_NUMBER}"
	else
		echo -e "Menggunakan Versi Terbaru ${PROJECT} Untuk Versi ${MINECRAFT_VERSION} Dibantu Dengan Versi API ${VHAPI_VERSION}"
		BUILD_NUMBER=${LATEST_BUILD}
	fi

	JAR_NAME=${PROJECT}-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar

	echo "Versi yang akan di download:"
	echo -e "Versi Minecraft: ${MINECRAFT_VERSION}"
	echo -e "Build: ${BUILD_NUMBER}"
	echo -e "JAR Name of Build: ${JAR_NAME}"
	echo -e "API VHC : ${VHAPI_VERSION}"
	DOWNLOAD_URL=https://papermc.io/api/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds/${BUILD_NUMBER}/downloads/${JAR_NAME}
fi

cd /mnt/server

echo -e "Menjalankan Perintah curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}"

if [ -f ${SERVER_JARFILE} ]; then
	mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

if [ ! -f server.properties ]; then
    echo -e "Men Download server.properties yang sudah di remake!"
    curl -o server.properties https://image.vhcid.tech/${VHAPI_VERSION}/minecraft-image/server.properties
fi

echo -e "Download dari VHAPI Image Versi : ${VHAPI_VERSION}"
curl -o 1-17-backup_master.tar.gz https://image.vhcid.tech/${VHAPI_VERSION}/minecraft-image/1.17/1-17-backup_master.tar.gz
tar -xvf 1-17-backup_master.tar.gz
rm 1-17-backup_master.tar.gz

#gak nemu biar bisa auto running anjir
