#!/bin/sh
## SCRIPT de IPTABLES 
## 
## Maquina con squid instalado para el filtrado de paquetes
##
##

printf "Aplicando Reglas de Firewall...\n"

# Variables del script
INTERNAL="eth0"
EXTERNAL="eth1"
FIREWALL="lo"

NETWORK_INT="192.168.1.0/24"

## FLUSH de reglas
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

## Establecemos politica por defecto
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

## Empezamos a filtrar
## Nota: eth0 es el interfaz conectado al router y eth1 a la LAN
# El localhost se deja (por ejemplo conexiones locales a mysql)
iptables -A INPUT -i $FIREWALL -j ACCEPT

# Al firewall tenemos acceso desde la red local
iptables -A INPUT -s $NETWORK_INT -i $INTERNAL -j ACCEPT

# Ejemplo de acceso remoto al local con acceso total
#iptables -A INPUT -s 195.65.34.234 -j ACCEPT

# Ejemplo de acceso remoto al local con acceso a mysql
#iptables -A INPUT -s 195.65.34.234 -p tcp --dport 20:21 -j ACCEPT

## Ahora con regla FORWARD filtramos el acceso de la red local
## al exterior. Como se explica antes, a los paquetes que no van dirigidos al 
## propio firewall se les aplican reglas de FORWARD

# Aceptamos que vayan a puertos 80
#iptables -A FORWARD -s 192.168.1.0/24 -i eth0 -p tcp --dport 80 -j ACCEPT
# Aceptamos que vayan a puertos https
#iptables -A FORWARD -s 192.168.1.0/24 -i eth0 -p tcp --dport 443 -j ACCEPT

# Redirigimos las llamadas al pureto 80 al equipo local puerto 3128
iptables -t nat -A PREROUTING -i $INTERNAL -p tcp --dport 80 -j REDIRECT --to-port 3128

# Aceptamos que consulten los Ping 
iptables -A FORWARD -s $NETWORK_INT -i $INTERNAL -p icmp --icmp-type 8 -j ACCEPT

# Aceptamos que consulten los DNS
iptables -A FORWARD -s $NETWORK_INT -i $INTERNAL -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -s $NETWORK_INT -i $INTERNAL -p udp --dport 53 -j ACCEPT

# Y denegamos el resto. Si se necesita alguno, ya avisaran y lo pasamos al log
iptables -A FORWARD -s $NETWORK_INT -i $INTERNAL -m limit --limit 5/m --limit-burst 7 -j LOG --log-prefix "SFW-INT-DROP TO: "
iptables -A FORWARD -s $NETWORK_INT -i $INTERNAL -j DROP

# Ahora hacemos enmascaramiento de la red local
# y activamos el BIT DE FORWARDING (imprescindible!!!!!)
iptables -t nat -A POSTROUTING -s $NETWORK_INT -o $EXTERNAL -j MASQUERADE

# Con esto permitimos hacer forward de paquetes en el firewall, o sea
# que otras máquinas puedan salir a traves del firewall.
echo 1 > /proc/sys/net/ipv4/ip_forward

## Y ahora cerramos los accesos indeseados del exterior:
# Nota: 0/0 significa: cualquier red

#LOG        tcp  --  0.0.0.0/0            0.0.0.0/0            limit: avg 3/min burst 5 tcp flags:0x17/0x02 LOG flags 6 level 4 prefix "SFW2-FWDdmz-DROP-DEFLT "
#LOG        icmp --  0.0.0.0/0            0.0.0.0/0            limit: avg 3/min burst 5 LOG flags 6 level 4 prefix "SFW2-FWDdmz-DROP-DEFLT "
#LOG        udp  --  0.0.0.0/0            0.0.0.0/0            limit: avg 3/min burst 5 ctstate NEW LOG flags 6 level 4 prefix "SFW2-FWDdmz-DROP-DEFLT "

iptables -A INPUT -s 0/0 -m limit --limit 5/m --limit-burst 7 -j LOG --log-prefix "SFW-EXT-DROP TO: "
iptables -A INPUT -s 0/0 -p tcp --dport 1:1024 -j DROP
iptables -A INPUT -s 0/0 -p udp --dport 1:1024 -j DROP

#iptables -A INPUT -j REJECT

printf "OK . Verifique que lo que se aplica con: iptables -L -n\n"

# Fin del script
