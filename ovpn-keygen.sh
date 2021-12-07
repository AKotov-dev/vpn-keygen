#!/bin/bash

#Script for creating a complete password-free configuration
#of the OpenVPN Client and Server in Mageia Linux
#Author: Alex Kotov aka alex_q_2000 (C) 2021
#License: GPLv3

# --- FOR THE MAINTAINER's ---
# Before building RPM/DEB packages, replace the ./easy-rsa directory with the native one:
# rm -rf /etc/openvpn/easy-rsa; cp -rf /usr/share/openvpn/easy-rsa /etc/openvpn/

# Сбрасываем атрибуты и определяем стиль шрифта
tput sgr0; color='\e[1m'; ncolor='\e[0m'

#Каталоги для клиента и сервера
[[ -d /etc/openvpn/client ]] || mkdir /etc/openvpn/client
[[ -d /etc/openvpn/server ]] || mkdir /etc/openvpn/server

#cp -rf /usr/share/openvpn/easy-rsa /etc/openvpn/
cd /etc/openvpn/easy-rsa
cp ./openssl-1.0.0.cnf ./openssl.cnf

sed -i 's/^export KEY_SIZE=.*/export KEY_SIZE=2048/g' ./vars
#sed -i 's/^export CA_EXPIRE=.*/export CA_EXPIRE=36500/g' ./vars
#sed -i 's/^export KEY_EXPIRE=.*/export KEY_EXPIRE=36500/g' ./vars

source ./vars

clear
echo -e "${color}OpenVPN KeyGen-v0.1${ncolor}
---"
# Указываем Порт и IP-адрес для конфигураций
read -p "Input remote server Port (default=1194): " p
read -p "Input remote server IP-Address (default=127.0.0.1): " a
# Если введены пустые значения
[[ -z ${p} ]] && p="1194"; [[ -z ${a} ]] && a="127.0.0.1"

echo -e "\n${color}Press 'Enter' to answer all the questions...${ncolor}"
./clean-all; ./build-ca
echo -e "\n${color}Press 'Enter', but if [y/n] suggests - enter 'y' and press 'Enter'...${ncolor}"
./build-key-server server
echo -e "\n${color}Press 'Enter', but if [y/n] suggests - enter 'y' and press 'Enter'...${ncolor}"
./build-key client
./build-dh
openvpn --genkey tls-auth /etc/openvpn/easy-rsa/keys/ta.key

# Пишем файл конфигурации Сервера
cat > /etc/openvpn/server/server.conf  << EOF
port ${p}

# TCP or UDP server?
;proto tcp
proto udp

dev tun

topology subnet
server 10.8.0.0 255.255.255.0

push "redirect-gateway def1 bypass-dhcp"

push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 208.67.220.220"

keepalive 10 120

cipher AES-256-CBC

comp-lzo no

persist-key
persist-tun

status openvpn-status.log

verb 3

# Notify the client that when the server restarts so it
# can automatically reconnect.
explicit-exit-notify 1

# "0" for server
key-direction 0

<ca>
$(cat /etc/openvpn/easy-rsa/keys/ca.crt)
</ca>

<tls-auth>
$(cat /etc/openvpn/easy-rsa/keys/ta.key)
</tls-auth>

<cert>
$(cat /etc/openvpn/easy-rsa/keys/server.crt)
</cert>

<key>
$(cat /etc/openvpn/easy-rsa/keys/server.key)
</key>

<dh>
$(cat /etc/openvpn/easy-rsa/keys/dh2048.pem)
</dh>
EOF

# --- Сервер настроен ---

# Пишем файл конфигурации Клиента
cat > /etc/openvpn/client/client.conf  << EOF
client
dev tun

remote ${a} ${p}
remote-random
nobind

persist-key
persist-tun

# The following setting is only needed for old OpenVPN clients compatibility.
# New clients automatically negotiate the optimal cipher.
cipher AES-256-CBC

auth SHA1
verb 2
mute 3
push-peer-info
ping 10
ping-restart 60
hand-window 70
server-poll-timeout 4
reneg-sec 2592000
sndbuf 393216
rcvbuf 393216
max-routes 1000
remote-cert-tls server
comp-lzo no

# "1" for client
key-direction 1

<ca>
$(cat /etc/openvpn/easy-rsa/keys/ca.crt)
</ca>

<tls-auth>
$(cat /etc/openvpn/easy-rsa/keys/ta.key)
</tls-auth>

<cert>
$(cat /etc/openvpn/easy-rsa/keys/client.crt)
</cert>

<key>
$(cat /etc/openvpn/easy-rsa/keys/client.key)
</key>
EOF

# --- Клиент настроен ---

# Показываем, что конфигурация - это ещё и *.ovpn
cp -f /etc/openvpn/client/client.conf /etc/openvpn/client/client.ovpn

# Простейший скрипт запуска сервера
cat > /etc/openvpn/server/start-server.sh << EOF
#!/bin/bash

sysctl -w net.ipv4.ip_forward=1
openvpn --config /etc/openvpn/server/server.conf

exit 0;
EOF

# Простейший скрипт запуска клиента
cat > /etc/openvpn/client/start-client.sh << EOF
#!/bin/bash

sysctl -w net.ipv4.ip_forward=1
openvpn --config /etc/openvpn/client/client.conf

exit 0;
EOF

# Безопасность, права
chown root:root /etc/openvpn/server/* /etc/openvpn/client/*; chmod 600 /etc/openvpn/server/*
chmod 775 /etc/openvpn/server/start-server.sh /etc/openvpn/client/start-client.sh

# Создаём архив всех нужных файлов для серевера и клиента (на случай переноса)
tar cfz /etc/openvpn/server+client.tar.gz /etc/openvpn/{client,server} &>/dev/null

clear
echo -e "${color}Server and client are configured:${ncolor}
---
Simple starting the client: /etc/openvpn/client/start-client.sh
Client combined configuration: /etc/openvpn/client/{client.conf or client.ovpn}

Simple starting the server: /etc/openvpn/server/start-server.sh
Server combined configuration: /etc/openvpn/server/server.conf

Client management sample:
systemctl enable openvpn-client@client.service
systemctl restart openvpn-client@client.service

Server management sample:
systemctl enable openvpn-server@server.service
systemctl restart openvpn-server@server.service

Don't forget to configure your iptables! Good luck! :)
---"

read -p "To exit, press 'Enter'..."

exit 0;
