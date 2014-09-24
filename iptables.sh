#!/bin/sh
#################################################################
#
# SCRIPT de IPTABLES 
# 
# Maquina con squid instalado para el filtrado de paquetes
#
# Carlos Val Gascón carlos.val@bifi.es
# 18/Oct/2014
#
#################################################################

printf "Aplicando Reglas de Firewall...\n"

# Variables del script
LAN="eth0"
INTERNET="eth1"
FIREWALL="lo"

NETWORK_INT="192.168.1.0/24"
SQUID_SERVER="192.168.1.1"
SQUID_PORT="3128"

## FLUSH de reglas
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

## Establecemos politica por defecto
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

## Empezamos a filtrar
## Acceso ilimitado a loop back
iptables -A INPUT  -i $FIREWALL -j ACCEPT
iptables -A OUTPUT -o $FIREWALL -j ACCEPT

# Al firewall tenemos acceso desde la red local
iptables -A INPUT -s $NETWORK_INT -i $LAN -j ACCEPT
iptables -A OUTPUT -s $NETWORK_INT -o $LAN -j ACCEPT

# Estable el equipo como router para el resto de la LAN
#iptables --table nat --append POSTROUTING --out-interface $INTERNET -j MASQUERADE
#iptables --append FORWARD --in-interface $LAN -j ACCEPT

# Redirigimos las llamadas al puerto 80 al equipo local puerto 3128
#iptables -t nat -A PREROUTING -i $LAN -p tcp --dport 80 -j REDIRECT --to-port $SQUID_PORT
iptables -t nat -A PREROUTING -i $LAN -p tcp --dport 80 -j DNAT --to $SQUID_SERVER:$SQUID_PORT

# Aceptamos que consulten los Ping 
iptables -A FORWARD -s $NETWORK_INT -i $LAN -p icmp --icmp-type 8 -j ACCEPT

# Aceptamos que consulten los DNS
iptables -A FORWARD -s $NETWORK_INT -i $LAN -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -s $NETWORK_INT -i $LAN -p udp --dport 53 -j ACCEPT

# Y denegamos el resto. Si se necesita alguno, ya avisaran y lo pasamos al log
iptables -A FORWARD -s $NETWORK_INT -i $LAN -m limit --limit 5/m --limit-burst 7 -j LOG --log-prefix "SFW-INT-DROP TO: "
iptables -A FORWARD -s $NETWORK_INT -i $LAN -j DROP

# Ahora hacemos enmascaramiento de la red local
# y activamos el BIT DE FORWARDING (imprescindible!!!!!)
iptables -t nat -A POSTROUTING -s $NETWORK_INT -o $INTERNET -j MASQUERADE

# Con esto permitimos hacer forward de paquetes en el firewall, o sea
# que otras máquinas puedan salir a traves del firewall.
echo 1 > /proc/sys/net/ipv4/ip_forward

## Y ahora cerramos los accesos indeseados del exterior:
iptables -A INPUT -s 0/0 -m limit --limit 5/m --limit-burst 7 -j LOG --log-prefix "SFW-EXT-DROP TO: "
iptables -A INPUT -s 0/0 -p tcp --dport 1:1024 -j DROP
iptables -A INPUT -s 0/0 -p udp --dport 1:1024 -j DROP

printf "OK . Verifique que lo que se aplica con: iptables -L -n\n"

# Fin del script
