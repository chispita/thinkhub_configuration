# Guía de la Instructura: ThinkHub en CaixaForum Zaragoza

## Introducción
En esta guía vamos a ver las diferentes configuraciones seguidas para 
la creación de la insfractructura necesaria para el experimento 
ThinkHub en CaixaForum.

En la ubicación de CaixaForum Zaragoza se desarrollará el experimento 
ThinkHub con aproximadamente 80 alumnos divididos en dos salas de unas 
40 persona cada una.

## Infrastructura
La infrastructura que dispondremos en el edificio será de un ADSL de 
unas 10 Mb y cableado físico para los distintos ordenadores que se 
procurarán que sean portátiles.

Como el ADSL será limitado y habrá muchos ordandores habrá que montar una 
insfrastructura para limitar el acceso a internet de los mismos de forma 
que solo puedan acceder a las páginas del experimento.

Para ello se instalará un ordenador que hará de Firewall y que tendrá dos 
tarjetas de red, una para la conexión al adsl y otra a un switch de la 
red interna que se creará para el evento. Este ordenador tendrá la finalidad 
de hacer de proxy (con un servicio squid) a Internet y de cortar todas las 
demás conexiones. Además se leventará un servicio de dhcp para que todos los 
ordenadores conectados compartan una misma red local.

### Firewal
Al los equipos dentro de la red solo se les permitira:
 - Hacer ping a máquinas remotas.
 - Hacer peticiones dns.
 - Acceder a páginas web a través de un proxy.

 - [Configuration] (iptables.sh)

### DHCP
 - [Configuration] (dhcpd.conf)

### Squid
 - [Configuration] (squid.conf)

## Tareas
- [X] Reglas del Firewall
- [ ] Hacer que el dns interno responda a la ip del proxy.
- [ ] Traducir los mensajes de error del squid con logos de Ibercivis.
- [ ] Que no haya que configurar el proxy y que coja por defeto el gateway.


Carlos Val Gascón
