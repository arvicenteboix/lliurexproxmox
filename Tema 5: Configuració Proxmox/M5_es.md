---
# Front matter
# Metainformació del document
title: "Configuración de Proxmox"
author: [Alfredo Rafael Vicente Boix y Javier Estellés Dasi \newline Modificado por Sergio Balaguer]
dato: "05-05-2024"
subject: "Proxmox"
keywords: [Red, Instalación]
subtitle: "Ejemplo de configuración"


lang: es
page-background: img/bg.png
titlepage: true
# portada
titlepage-rule-height: 2
titlepage-rule-color: AA0000
titlepage-text-color: AA0000
titlepage-background: ../portades/U5.png

# configuració de l'índex
toc-own-page: true
toc-title: Continguts
toc-depth: 2

# capçalera i peu
header-left: \thetitle
header-right: Curs 2023-2024
footer-left: CEFIRE València
footer-right: \thepage/\pageref{LastPage}

# Les figures que apareguen on les definim i centrades
float-placement-figure: H
caption-justification: centering 

# No volem numerar les linies de codi
listings-disable-line-numbers: true

# Configuracions dels paquets de latex
header-includes:

  #  imatges i subfigures
  - \usepackage{graphicx}
  - \usepackage{subfigure}
  - \usepackage{lastpage}



  #  - \usepackage{adjustbox}
  # marca d'aigua
  #- \usepackage{draftwatermark}
 # - \SetWatermarkText{\includegraphics{./img/Markdown.png}}
  #- \SetWatermarkText{Per revisar}
  #- \SetWatermarkScale{.5}
  #- \SetWatermarkAngle{20}
   
  # caixes d'avisos 
  - \usepackage{awesomebox}

  # text en columnes
  - \usepackage{multicol}
  - \setlength{\columnseprule}{1pt}
  - \setlength{\columnsep}{1em}

  # pàgines apaïsades
  - \usepackage{pdflscape}
  
  # per a permetre pandoc dins de blocs Latex
  - \newcommand{\hideFromPandoc}[1]{#1}
  - \hideFromPandoc {
      \let\Begin\begin
      \let\End\end
    }
 
# definició de les caixes d'avis
pandoc-latex-environment:
  noteblock: [note]
  tipblock: [tip]
  warningblock: [warning]
  cautionblock: [caution]
  importantblock: [important]
...

\vspace*{\fill}

![](img/cc.png){ height=50px }

Este documento está sujeto a una licencia creative commons que permite su difusión y uso comercial reconociendo siempre la autoría de su creador. Este documento se encuentra para ser modificado en el siguiente repositorio de github:
<!-- CAMBIAR EL ENLACE -->
[https://github.com/arvicenteboix/lliurexproxmox](https://github.com/arvicenteboix/lliurexproxmox)
\newpage
<!-- \awesomebox[violet]{2pt}{\faRocket}{violet}{Lorem ipsum…} -->

# Introducción

En esta Unidad configuraremos el hipervisor con PROXMOX. Montaremos 3 servidores con las siguientes características.

| Servidor | Características |
| -- | -- |
| MASTER | Tendrá el LDAP y guarda el /net |
| CENTRO | DHCP a los ordenadores del centro |
| AULA1 | DHCP a los ordenadores del aula de informática |
| WIFI |No montaremos el servidor WIFI en esta unidad |

Daremos como ejemplo dos esquemas de montaje de centro. Los dos son totalmente válidos pero **nos centraremos en el primero en este curso** ya que el segundo ejemplo es para instalaciones que no tienen switches gestionables. 

:::note
La mayoría de capturas de pantalla están en inglés ya que viene por defecto. Obviamente si alguien quiere configurar los parámetros en la ventana de login al catalán o al español lo puede hacer sin problemas.
:::

## Esquema 1

En este esquema tenemos como ejemplo el switch principal del centro con *1 LAG de 4 puertos* conectado a las cuatro tarjetas de red del servidor. También conectamos la tarjeta de red de la placa base del servidor a una boca del switch.

El esquema seria de la siguiente manera:

![Esquema orientativo 1](Esquemes/esquemabond.png)




## Esquema 2

En el siguiente esquema no se usan switches gestionables por lo que no se usan VLANs. Cada tarjeta del hipervisor va a un switch diferente. Este esquema no aprovecha las ventajas que tiene un LAG (aumento ancho de banda y tolerancia a fallos).Este montaje se utiliza principalmente en centros pequeños. El equema seria de la siguiente manera:

![Esquema orientativo 2](Esquemes/esquemasense.png)

## Clúster 
En este tema vamos a configurar un solo hipervisor pero si tenemos más hipervisores habría que crear más LAGs en el switch y la misma configuración de PROXMOX en todos los hipervisores. Una vez estuviera todo conectado, configurado y en marcha se pueden unir los servidores PROXMOX en un **clúster**. El clúster permite gestionar todos los servidores PROXMOX de forma unificada, mover VM de un PROXMOX a otro y más cosas que **veremos en el próximo tema**. 

## Alta disponibilidad

Una vez hemos creado un clúster podemos mejorarlo con la alta disponibilidad. La alta disponibilidad (HA) permite que cuando un hipervisor se estropea los otros cogen de forma automática las máquinas virtuales del mismo y siguen dando servicio sin que el usuario lo note. Esto permite cambiar el hipervisor o arreglarlo y el servicio no es interrumpido en ningún momento. Para hacer esto es necesario montar un [CEPH](https://es.wikipedia.org/wiki/Ceph_File_System) o tener una cabina/NAS de discos externa con mucha fiabilidad (y muy caras). En estas cabinas es donde se guardan los discos de todas las VM y ya no estarían almacenados en los discos de los servidores PROXMOX. Esta configuración no se va a tratar en este curso.


## Esquema de máquinas virtuales (VM)

En ambos esquemas la configuración de las máquinas virtuales es igual ya que la configuración de donde se conectan las tarjetas virtuales se hace desde el PROXMOX. Hemos respetado los nombres de las tarjetas en ambos casos (**vmbrX**), pero se puede dar el nombre que quieras.

![Esquema conexiones máquinas virtuales](Esquemes/Conexionshipervisor.png)

# Configuración del PROXMOX

Una vez tenemos instalado PROXMOX y haya reiniciado, podremos acceder en él. Toda la configuración del PROXMOX se realiza a través de un servidor web que lleva el sistema. Para acceder tenemos que hacerlo a través del puerto 8006 con certificación ssl. Sencillamente escribimos en un navegador de una estación de trabajo que esté en la misma red lo siguiente:

```tcsh
https://"IP_HIPERVISOR:8006
```

:::note
Este es uno de los motivos por los cuales dejamos puertos en cada switch con la VLAN 1, para poder acceder a través de esos puertos siempre al PROXMOX. También se puede hacer desde cualquier ordenador del centro o el aula de informática, pero hay que habilitar el NAT en cada servidor LliureX. Y estos tienen que estar funcionando. Por lo tanto es necesario estar conectado en la red del centro.
:::

## Máquinas virtuales

Lo primero que nos pide es el usuario y contraseña que hemos configurado cuando hemos hecho la instalación:

![Esquema orientativo 2](ConProxmox/prox1.png)

Y una vez dentro podemos ver el espacio de trabajo del PROXMOX:

![Esquema orientativo 2](ConProxmox/prox2.png)

:::note
Los siguientes pasos son opcionales, pero aconsejables. Es para acceder a las últimas actualizaciones de PROXMOX.
:::

Una vez hemos accedido podemos configurar la lista de los repositorios de PROXMOX accediendo, en primer lugar al shell del hipervisor y escribimos lo siguiente:

```tcsh
nano /etc/apt/sources.list.d/pve-enterprise.list
```
Ten en cuenta que has accedido como root, así que tienes que ir con mucho cuidado con lo que haces. Una vez abres el fichero cambias el repositorio por el siguiente:

```tcsh
deb http://download.proxmox.com/debian/pve buster pve-no-subscription
```

Se quedaría así:

![Repositorio de PROXMOX](ConProxmox/prox3.png)

Ahora ya puedes actualizar desde la terminal el PROXMOX para tener la última versión:

```tcsh
apt update
apt upgrade
```

## Crear máquina virtual

Antes de crear una máquina virtual tenemos que subir la iso de LliureX Server, podemos descargarla [de aquí](http://releases.lliurex.net/isos/21.07_64bits/LliureX-server_64bits_21_latest.iso). Tratamos de buscar la última versión editada.

Una vez ya tenemos la descarga es necesario subirla al PROXMOX, lo hacemos seleccionando el espacio **local** y haciendo click en **upload**:

![Subir iso a PROXMOX](ConProxmox/prox5.png)

![Subir iso a PROXMOX](ConProxmox/prox6.png)

Una vez tenemos hecho esto, ya podemos crear la primera maquina virtual. Haremos de ejemplo el servidor MASTER y los otros se hacen de manera similar. Hagamos click sobre **Create VM**.

![Crear máquina virtual](ConProxmox/prox7.png)

Se abrirá una ventana para especificar los parámetros de configuración. En la primera ventana no hay que cambiar nada, vamos a **Next**:

![Pulsamos next](ConProxmox/prox8.png)

En este punto tenemos que seleccionar la iso que acabamos de subir:

![Seleccionamos ISO](ConProxmox/prox9.png)

Posteriormente damos a next:

![Opciones del sistema](ConProxmox/prox10.png)

Escogemos el disco a utilizar, y opcionalmente cambiamos la cache a **write back**.

:::note
**Write-back** puede dar un poco más de rendimiento al disco pero es más propenso a perder datos si hay un corte. Queda a criterio de cada cual escoger.
:::

:::important
Dependiendo del tamaño del centro el disco del servidor lliurex MAESTRO necesitará más espacio. Es aconsejable añadir un disco grande como por ejemplo un 1TB o más ya que almacenará los datos de todo el alumnado, profesorado, mirror, clientes ligeros, clonaciones, etc. En los servidores ESCLAVOS no es necesario tanto espacio (150GB por ejemplo) ya que montan /net del MAESTRO.
:::

![Opciones del disco](ConProxmox/prox11.png)

Cambiamos los parámetros de la CPU, en principio 4 cores en total es suficiente para las tareas a realizar.

![Opciones del disco](ConProxmox/prox12.png)

Damos 6Gb de memoria RAM. Este parámetro irá siempre en función de la cantidad de máquinas que vayamos a tener.

:::caution
La suma de la memoria RAM de todas las máquinas puede ser sin problemas mayor que la cantidad de memoria RAM disponible. Eso sí, si todas las máquinas empiezan a pedir mucha memoria, el sistema se puede volver muy lento o colapsar. Así que no es recomendable.
:::

![Memoria RAM](ConProxmox/prox13.png)

Finalmente, no cambiamos nada a los parámetro de red y una vez instalada la máquina ya añadiremos las tarjetas virtuales. 

![Red](ConProxmox/prox14.png)

Podemos activar el checkbox de **Start after created** para poder iniciar la máquina una vez le damos a **Finish**.

![Finalización de configuración VM](ConProxmox/prox15.png)


## Instalación de la máquina virtual

Una vez configurada la máquina virtual y haya arrancado podemos ver como nos aparece un icono en la franja izquierda y se pone de color, podemos desplegar el menú contextual y pulsar sobre **Console**:

![Menú contextual de la VM en funcionamiento](ConProxmox/prox16.png)

Podemos ver cómo ha arrancado la máquina:

![Inicio de máquina virtual](ConProxmox/prox17.png)

Y procedemos a su instalación tal y como hemos visto a la Unidad 1.

De manera similar, si queremos seguir todo el proceso habría que instalar los otros dos servidores ESCLAVOS con el mismo procedimiento. Lo único que hay que cambiar entre ellos sería el nombre de cada uno de ellos y el tamaño del disco, nosotros hemos escogido la siguiente nomenclatura:

| Nombre | Servidor |
| -- | -- |
| 4600xxxx.MAS | Servidor Master |
| 4600xxxx.CEN | Servidor de centro |
| 4600xxxx.AU1 | Servidor Aula informática |

Y para el administrador de cada uno de los servidores hemos escogido **admin0**.

# Configuración de la red

Una vez tenemos instalados todos los servidores procedemos a configurar la red. Para acceder a la configuración del hipervisor tenemos que seleccionar el icono del hipervisor (no la máquina virtual ni el Datacenter), y vamos a las opciones **Network**.

## Esquema 1

Recordemos que este esquema tiene un **bond** al switch. Pulsamos sobre **Create** y seleccionamos la opción **Linux Bond**.

![Selección de bond](ConProxmox/prox18.png)

Se nos abrirá la ventana siguiente y tenemos que escribir todas las tarjetas donde pone **Slaves**, seguidas de un espacio. La configuración quedaría de las siguiente manera:

| Parámetro | Opción |
| -- | -- |
| Slaves | enp1s0 enp2s0 enp3s0 enp4s0 |
| Modo | LACP |
| hash-policy | layer2+3 |

Y polsem sobre **Create**.

![Configuración del bond](ConProxmox/prox21.png)

Una vez tenemos configurado el bond pulsamos otra vez a **Create** y seleccionamos **Linux Bridge**. En la opción **Bridge ports** tenemos que escribir el bond0 seguido de un punto y el número de VLAN que queremos configurar a la conexión puente.

![Configuración de la conexión puente](ConProxmox/prox22.png)

De manera análoga realizamos todas las otras configuraciones y nos quedaría de la siguiente manera:

![Configuración de redes en el PROXMOX](ConProxmox/prox23.png)

## Esquema 2

:::important
Recordamos que este esquema **no es el que utilizaremos en este curso** pero se enseña para casos en los que no se disponga de switches gestionables ni VLANs.
:::

Este esquema que no presenta ninguna VLAN se haría de manera análoga al anterior, pero sin configurar el bond. Cogeríamos cada tarjeta virtual Linux bridge y la enlazamos a la tarjeta de salida. El esquema quedaría de la siguiente manera:

![Configuración de redes en el PROXMOX](ConProxmox/prox46xxx.png)

:::caution
Uno de los problemas que presenta esta configuración es saber qué tarjeta es cada una, podemos ir probando y ver cuál está activa con la herramienta **ip** para saber cuál es. Podemos ir desconectando los cables para ver que aparece state DOWN y asociar la conexión.
:::

```tcsh
root@cefirevalencia:~# ip link show enp4s0
5: enp4s0: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 state DOWN mode DEFAULT group default qlen 1000
``` 

:::note
Tanto en el **esquema 1** (el que usaremos en este curso) como el **esquema 2** el nombre de las tarjetas es el mismo (vmbrXX). Por tanto la configuración de las tarjetas de red en las VM será exactamente igual.
:::

# Configuración de la red en cada máquina virtual



Tenemos que recordar que cada servidor LliureX debe tener 3 tarjetas:

| Tarjeta | Características |
| -- | -- |
| Tarjeta externa | Es la que se conectará en la red de Aulas |
| Tarjeta interna | Conectada a los ordenadores del aula o las clases |
| Tarjeta de replicación | Para montar el /net entre los servidores |

En nuestro caso recordamos que las tenemos configuradas de la siguiente manera:

| Tarjeta | nombre |
| -- | -- |
| Tarjeta externa | vmbr0 |
| Tarjeta interna | vmbr2, vmbr3, vmbr4, vmbr5 |
| Tarjeta de replicación | vmbr10 |

Para configurar cada máquina virtual seleccionamos la máquina y vamos a las opciones de **Hardware**, hacemos click sobre **Add** y escogemos **Network device**.

![Configuración de red de VM](ConProxmox/prox24.png)

Como cuando hemos instalado la máquina virtual ya nos ha cogido la vmbr0, esa la dejamos como la externa. Y configuramos ya la interna.

![Configuración de tarjeta virtual](ConProxmox/prox25.png)

Este procedimiento lo tenemos que repetir en todos los servidores. Recuerda que el esquema de red es el siguiente:

| IP | Servidor |
| -- | -- |
| 172.X.Y.254 | Servidor Maestro |
| 172.X.Y.253 | Servidor de Centro |
| 172.X.Y.252 | Servidor de Aula 1 |
| 172.X.Y.251 | Servidor de Aula 2 |
| 172.X.Y.250 | Servidor de Aula 3 |

## Tarjetas virtuales

:::warning
Es importante que nos aseguremos antes de inicializar el servidor qué tarjeta es cual, es importante no confundirse. El servidor podría empezar a dar DHCP a través de tarjeta conectada a la VLAN1 o router (dependiente del esquema) y podría dejar sin servicio a todo el centro.
:::

Podemos comprobar cuál es cada tarjeta con el comando ip en al servidor y comparar las MAC.

![Configuración de red de VM](ConProxmox/prox26.png)

## Inicialización servidores

Cuando iniciamos el servidor, en este caso el MÁSTER, escogemos las siguientes opciones:

![Inicializar el servidor](ConProxmox/prox27.png)

:::warning
Es muy importante que habilites la opción de ***exportar*** el /net al servidor maestro.
:::

Un procedimiento extra que no nos tiene que olvidar en ningún servidor es actualizarlos siempre antes de hacer nada. Y en el MÁSTER tenemos que configurar el lliurex mirror:

![Mirror](ConProxmox/prox29.png)

![Mirror](ConProxmox/prox30.png)

![Mirror](ConProxmox/prox31.png)

De manera similar inicializamos los otros servidores:

![Inicializar el servidor](ConProxmox/prox32.png)

:::warning
Es muy importante que habilites la opción ***monta*** el /net desde el maestro.
:::

# Configuraciones adicionales

## Arrancar las máquinas virtuales cuando inicia el servidor

Es importante que cuando se reinicie el hipervisor las máquinas virtuales arranquen automáticamente para no tener que conectarse al PROXMOX para ponerlas en marcha una a una. Para configurar esta opción seleccionaremos una máquina virtual y seleccionaremos la opción de configuración **Options** y cambiaremos los parámetros **Start at boot** a **Yes** y **Start/Shutdown order** a 1 en el caso del servidor maestro.

:::caution
Es recomendable arrancar primero el maestro y dejar un tiempo para que arranque y posteriormente arrancar los esclavos. Así, en los servidores esclavos añadiremos un tiempo a **Startup delay**.
:::

![Configuración de orden de arrancada](ConProxmox/prox33.png)

![Configuración de orden de arrancada](ConProxmox/prox34.png)

En el servidor de centro y esclavo las opciones quedarían de la siguiente manera:

![Configuración de orden de arranque en el servidor de centro](ConProxmox/prox35.png)

![Configuración de orden de arranque en el servidor del aula de informática](ConProxmox/prox36.png)

## Montaje de cabina externa (Opcional)

Es posible que nos interese la opción de una cabina externa. Tiene numerosas ventajas, en el espacio de la cabina externa podemos tener almacenado isos, discos duros de máquinas virtuales, copias de seguridad...

:::note
Lo que se explica en este punto no es para conseguir la alta disponibilidad (HA). Es para añadir un almacenamiento común al clúster donde hacer backups, almacenar el disco de alguna VM, isos, etc. Las cabinas no entran dentro de la dotación, por lo tanto sería una adquisición propia del centro y no se tratará en este curso como se configuran.
:::

:::warning
Existe la posibilidad de almacenar /net del servidor maestro en una cabina externa. Según como se realice puede dar problema con las ACL de los archivos y no funcioná.
La opción para conseguir esto es crear un segundo disco virtual en el servidor maestro pero almacenarlo en la cabina externa. Cuando se realiza la instalación de la VM (en el apartado de particionamiento de disco) se indicaría que ese segundo disco se usará para /net. Esto funciona perfectamente ya que para la VM es como si fuera un disco local.

Además, para hacer esto es aconsejable que la cabina tenga unas características adecuadas. Se recomendaría como mínimo:

* Posibilidad de crear un bond con 4 tarjetas de red, o tarjeta de 10G (haría falta un switch que lo soporte) 
* Al menos 4 discos duros para montar un RAID10 
* Cache de disco SSD

Con estás características se podría montar incluso un sistema con Alta disponibilidad.
:::



Si el centro dispone de una cabina funcionando, configurada y conectada en la red del centro podemos añadirla a nuestro **Datacenter** seleccionándolo y yendo a la opción de **Storage**. Hagamos click sobre **Add** y escogemos **NFS**.

![Configuración de cabina](ConProxmox/prox37.png)

Y seleccionamos las diferentes opciones de configuración:

![Configuración de cabina](ConProxmox/prox38.png)

## Creación de backup (Opcional)

La creación de backups periodicos de las VM es muy aconsejable. En PROXMOX es muy fácil hacer backups de las VM y restaurarlos. Pueden suceder imprevistos como desconfigurar un servidor por error, borrar /net por error o cualquier desastre que nos podamos imaginar. En estos casos tener una copia de seguridad de nuestras VM es de gran utilidad.

:::note
Una cabina de discos o NAS con unas prestaciones modestas sería suficiente para realizar estas tareas. También se podría usar un segundo disco del hipervisor si no hemos hecho un RAID1.
::: 

 Para configurar la copia de seguridad seleccionamos el datacenter, vamos a la opción de Backup y hacemos click sobre Add. 

![Configuración de cabina](ConProxmox/prox39.png)

Nos aparecerá la siguiente ventana, tenemos que tener en cuenta en qué lugar queremos hacer el backup (**Storage**). Y seleccionamos la/las máquinas virtuales que queremos hacer copia de seguridad. En un principio, en nuestro caso solo habría que hacer la copia de seguridad del Máster, puesto que es donde se guarda el /net y LDAP. La copia de seguridad queda programada para una fecha determinada, en principio, en un centro podría ser un sábado a las 12 de la noche ya que no hay ningún usuario conectado.

![Configuración de la copia de seguridad](ConProxmox/prox40.png)

También se puede hacer una copia de seguridad en cualquier momento. Las copias de seguridad llevan tiempo, por lo tanto no es recomendable hacerlo en horas donde se estén utilizando los servidores.

![Creación de la copia de seguridad](ConProxmox/prox41.png)

![Creación de la copia de seguridad](ConProxmox/prox42.png)

Una vez tenemos la copia de seguridad hecha podemos restaurarla con **Restore**.

:::caution
Cuando se restaura la copia de seguridad se creará una nueva máquina virtual con las mismas características que la máquina antigua y nos preguntará en qué espacio queremos instalar la nueva máquina. Hemos de tener cuidado en no tener las dos máquinas funcionando al mismo tiempo (después de restaurarla) puesto que creará problemas de red. También hemos de recordar deshabilitar la opción de **Start at boot**, sino al reiniciar el hipervisor arrancarán las dos máquinas.
:::

![Restaurar la copia de seguridad](ConProxmox/prox43.png)

![Restaurar la copia de seguridad](ConProxmox/prox44.png)


# Bibliografía y referencias

(@) https://es.wikipedia.org/wiki/vlan
