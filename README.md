# openvpn-keygen & wireguard-keygen
Generators of combined client and server configurations for OpenVPN and WireGuard.

**RU**  
Зависимости: `openvpn openssl iptables`  
`openvpn-keygen.tar.gz` - генератор комбинированных (содержащих ключи внутри себя) конфигураций для клиента и сервера `OpenVPN` с использованием встроенного `EasyRsa`. Распакуйте архив, запустите `/etc/openvpn/openvpn-keygen` и следуйте инструкциям. Кроме конфигураций `*.ovpn и *.conf` будут созданы и простейшие скрипты запуска сервера и клиента. 

Зависимости: `wireguard iptables resolvconf`  
`wireguard-keygen.tar.gz` - генератор комбинированных конфигураций для клиента и сервера `WireGuard`. Распакуйте архив, запустите `/etc/wireguard/wireguard-keygen` и следуйте инструкциям. Кроме конфигураций `wg0.conf` и `wg0-client.conf`, содержащих ключи, будут созданы и простейшие скрипты запуска сервера и клиента.

**EN**  
Dependencies: `openvpn openssl iptables`  
`openvpn-keygen.tar.gz` - generator of combined configurations (containing keys inside themselves) for the `OpenVPN` client and server using the built-in `EasyRSA`. Unpack the archive, run `/etc/openvpn/openvpn-keygen` and follow the instructions. In addition to configurations containing keys `*.ovpn and *.conf`, the simplest server and client startup scripts will also be created. 

Dependencies: `wireguard iptables resolvconf`  
`wireguard-keygen.tar.gz` - generator of combined configurations for the `WireGuard` client and server. Unzip the archive, run `/etc/wireguard/wireguard-keygen` and follow the instructions. In addition to the configurations `wg0.conf` and `wg0-client.conf` containing keys, the simplest server and client startup scripts will also be created.
