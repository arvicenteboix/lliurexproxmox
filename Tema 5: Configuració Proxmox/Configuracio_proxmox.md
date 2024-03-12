---
title: "CONFIGURACIÓ DE XARXA"
author: [Alfredo Rafael Vicente Boix i Javier Estellés Dasi \newline Modificat per Sergio Balaguer]
date: "2020-11-25"
subject: "Proxmox"
keywords: [Xarxa, Instal·lació]
subtitle: "Exemple d'esquema de xarxa en el model de centre"
lang: "es"
page-background: "background10.pdf"
titlepage: true,
titlepage-rule-color: "360049"
titlepage-background: "background10.pdf"
colorlinks: true
toc-own-page: true
header-includes:
- |
  ```{=latex}
  \usepackage{awesomebox}
  \usepackage{caption}
  \usepackage{array}
  \usepackage{tabularx}
  \usepackage{ragged2e}
  \usepackage{multirow}


  ```
pandoc-latex-environment:
  noteblock: [note]
  tipblock: [tip]
  warningblock: [warning]
  cautionblock: [caution]
  importantblock: [important]
...

<!-- \awesomebox[violet]{2pt}{\faRocket}{violet}{Lorem ipsum…} -->

# Introducció

En aquesta Unitat configurarem l'hipervisor amb Proxmox. Muntarem 3 servidors amb les següents característiques.

| Servidor | Característiques |
| -- | -- |
| MASTER | Tindrà el LDAP i guarda el /net |
| CENTRE | DHCP als ordinadors del centre |
| AULA1 | DHCP als ordinadors de l'aula d'informàtica |
| WIFI |No muntarem el servidor WIFI en aquesta unitat |

Donarem com a exemple dos esquemes de muntatge del centre. Ambdós són totalment vàlids però **nos centrarem en el primer en este curso** ja que el segon exemple és per a instal·lacions que no tenen switches gestionables.

:::note
La majoria de captures de pantalla estan en anglés ja que ve per defecte. Òbviament si algú vol configurar els paràmetres en la finestra de loguet al català o a l'espanyol ho pot fer sense problemes
:::

## Esquema 1

En este esquema tenim com a exemple el switch principal del centre amb 1 LAG de 4 ports connectat a les quatre targetes de xarxa del servidor. També connectem la targeta de xarxa de la placa base del servidor a una boca del switch. 

L'esquema seriosa de la manera següent:


![Esquema orientatiu 1](Esquemes/esquemabond.png)

## Esquema 2

En el següent esquema no s'usen switches gestionables pel que no s'usen VLANs. Cada targeta de l'hipervisor va a un switch diferent. Este esquema no aprofita els avantatges que té un LAG (augment amplada de banda i tolerància a fallades). Este muntatge s'utilitza principalment en centres xicotets. 

L'equema seriosa de la manera següent:

![Esquema orientatiu 2](Esquemes/esquemasense.png)

## Clúster 

En este tema configurarem un sol hipervisor però si tenim més hipervisors caldria crear més LAGs en el switch i la mateixa configuració de PROXMOX en tots els hipervisors. Una vegada estiguera tot connectat, configurat i en marxa es poden unir els servidors PROXMOX en un **clúster**. El clúster permet gestionar tots els servidors PROXMOX de forma unificada, moure VM d'un PROXMOX a un altre i més coses que **veurem en el pròxim tema**.

## Alta disponibilitat 

Una vegada hem creat un cluster podem millorar-ho amb l'alta disponibilitat. L'alta disponibilitat (HA) permet que quan un hipervisor s'espatla els altres agafen de forma automàtica les màquines virtuals del mateix i continuen donant servici sense que l'usuari ho note. Açò permet canviar l'hipervisor o arreglar-ho i el servici no és interromput en cap moment. Per a fer açò és necessari muntar un [CEPH] (https://es.wikipedia.org/wiki/Ceph_File_System) o tindre una cabina/NAS de discos externa amb molta fiabilitat (i molt cares). En estes cabines és on es guarden els discos de totes les VM i ja no estarien emmagatzemats en els discos dels servidors PROXMOX. Esta configuració no es va a tractar en este curs.

## Esquema de màquines virtuals (VM)

En tots dos esquemes la configuració de les màquines virtuals és igual ja que la configuració d'on es connecten les targetes virtuals es fa des del PROXMOX. Hem respectat els noms de les targetes en tots dos casos (***vmbrX**), però es pot donar el nom que vulgues.

![Esquema connexions màquines virtuals](Esquemes/Conexionshipervisor.png)

# Configuració del proxmox

Una vegada tenim instal·lat PROXMOX i haja reiniciat, podrem accedir a ell. Tota la configuració del proxmox es realitza a través d'un servidor web que porta muntat. Per a accedir hem de fer-ho a través del port 8006 amb certificació ssl. Senzillament escrivim a una navegador d'una estació de treball que estiga a la mateixa xarxa el següent:

```tcsh
https://"IP_HIPERVISOR:8006
```

::: info
Este és un dels motius pels quals deixem ports en cada switch amb la VLAN 1, per a poder accedir a través d'eixos ports sempre al proxmox. També es pot fer des de qualsevol ordinador del centre o l'aula d'informàtica, però cal habilitar el NAT en cada servidor LliureX. I estos han d'estar funcionant. Per tant en aquest pas és necessari estar connectat a la xarxa del centre.
:::

## Màquines virtuals

El primer que ens demana és l'usuari i contrasenya que hem configurat quan hem fet la instal·lació:

![Esquema orientatiu 2](ConProxmox/prox1.png)

I una vegada dins podem veure l'espai de treball del proxmox:

![Esquema orientatiu 2](ConProxmox/prox2.png)

:::note
Els següents passos són opcionals, però aconsellables. És per a accedir a les últimes actualitzacions de proxmox.
:::

Una vegada hem accedit podem configurar la llista dels repositoris de proxmox accedint, en primer lloc al shell del hipervisor i escrivim el següent:

```tcsh
nano /etc/apt/sources.list.d/pve-enterprise.list
```
Tin en compte que has accedit com a root, així que has d'anar molt amb compte amb el que fas. Una vegada obris el fitxer canvies el repositori pel següent:

```tcsh
deb http://download.proxmox.com/debian/pve buster pve-no-subscription
```

Es quedaría així:

![Repositori de proxmox](ConProxmox/prox3.png)

Ara ja pots actualitzar des de la terminal el proxmox per a tenir l'última versió:

```tcsh
apt update
apt upgrade
```

## Crear màquina virtual

Abans de crear una màquina virtual hem de pujar un iso de LliureX Server, podem descarregar-la [d'ací](http://releases.lliurex.net/isos/21.07_64bits/LliureX-server_64bits_21_latest.iso). Tractem de buscar l'última versió editada.

Una vegada la tenim descarrega hem de pujar-la al proxmox seleccionant l'espai **local** i fent click en upload:

![Pujar iso a proxmox](ConProxmox/prox5.png)

![Pujar iso a proxmox](ConProxmox/prox6.png)

Una vegada tenim fet això, ja podem crear la primera maquina virtual. Farem d'exemple el servidor MASTER i els altres es fan de manera similar. Fem click sobre **Create VM**

![Crear màquina virtual](ConProxmox/prox7.png)

S'obrirà una finestra per a especificar els paràmetres de configuració. En la primera finestra no cal canviar res, anem a **Next**:

![Polsem next](ConProxmox/prox8.png)

En aquest punt hem de seleccionar la iso que acabem de pujar:

![Seleccionem ISO](ConProxmox/prox9.png)

Posteriorment donem a next:

![Opcions del sistema](ConProxmox/prox10.png)

Escollim el disc dur a utilitzar, i opcionalment canviem la cache a write back. 

:::note
Write-back pot donar un poc més de rendiment al disc però és més propens a perdre dades si hi ha un tall. Queda a criteri de cadascú escollir.
:::

:::important
Depenent de la grandària del centre el disc del servidor lliurex MESTRE necessitarà més espai. És aconsellable afegir un disc gran com per exemple un 1TB o més ja que emmagatzemarà les dades de tot l'alumnat, professorat, mirror, clients lleugers, clonacions, etc. En els servidors ESCLAUS no cal tant espai (150GB per exemple) ja que munten /net del MESTRE.
:::

![Opcions del disc dur](ConProxmox/prox11.png)

Canviem els paràmetres de la CPU, 4 cores en total és suficient, en principi per a les tasques a realitzar.

![Opcions del disc dur](ConProxmox/prox12.png)

Donem 6Gb de memòria RAM. Aquest paràmetre anirà sempre en funció de la quantitat de màquines que anem a tindre.

:::caution
La suma de la memòria RAM de totes les màquines pot ser sense problemes major que la quantitat de memòria RAM disponible. Això sí, si totes les màquines comencen a demanar molta memòria, el sistema es pot tornar molt lent.
:::

![Memòria RAM](ConProxmox/prox13.png)

Finalment, no canviem res als paràmetre de xarxa i una vegada instal·lada la màquina ja afegirem les targetes virtuals.

![Xarxa](ConProxmox/prox14.png)


 Podem activar el checkbox de **Start after created** per a poder iniciar la màquina una vegada li donem a **Finish**.

![Resum d'opcions](ConProxmox/prox15.png)

## Instal·lació de la màquina virtual

Una vegada configurada la màquina virtual i haja arrancat podem veure com ens apareix una icona en la franja esquerra i es posa de color, podem desplegar el menú contextual i polsem sobre Console:

![Menú contextual de la VM en funcionament](ConProxmox/prox16.png)

Podem veure com ha arrancat la màquina:

![Inici de màquina virtual](ConProxmox/prox17.png)

I procedim a la seua instal·lació tal i com hem vist a la Unitat 1.

De manera similar, si volem seguir tot el procés caldria instal·lar els altres dos servidors ESCLAUS amb le mateix procediment. L'única cosa que cal canviar entre ells seria el nom de cadascún d'ells i la grandària del disc, nosaltres hem escollit la següent nomenclatura:

| Nom | Servidor |
| -- | -- |
| 4600xxxx.MAS | Servidor Master |
| 4600xxxx.CEN | Servidor de centre |
| 4600xxxx.AU1 | Servidor Aula informàtica |

I per a l'administrador de cadascun dels servidor hem escollit **admin0**. 

# Configuració de la xarxa

Una vegada tenim instal·lats tots els servidors procedim a configurar la xarxa. Per a accedir a la configuració de l'hipervisor hem de seleccionar la icona de l'hipervisor (no la màquina virtual ni el Datacenter), i anem a les opcions **Network**.

## Esquema 1

Recordem que aquest esquema té un bond al switch. Polsem sobre **Create** i seleccionem l'opció **Linux Bond**.

![Selecció de bond](ConProxmox/prox18.png)

S'ens obrirà la finestra següent i hem d'escriure totes les targetes on posa **Slaves**, seguides d'un espai. La configuració quedaria de las següent manera:

| Paràmetre | Opció |
| -- | -- |
| Slaves | enp1s0 enp2s0 enp3s0 enp4s0 |
| Mode | LACP |
| hash-policy | layer2+3 |

I polsem sobre **Create**.

![Configuració del bond](ConProxmox/prox21.png)

na vegada tenim configurat el bond anem altra vegada a **Create** i seleccionem **Linux Bridge**. A l'opció **Bridge ports** hem d'escriure el bond0 seguit d'un punt i el número de VLAN que volen configurar a la connexió pont.

![Configuració de la connexió pont](ConProxmox/prox22.png)

De manera anàloga realitzem totes les altres configuracions i ens quedaria de la següent manera:

![Configuració de xarxes al proxmox](ConProxmox/prox23.png)

## Esquema 2

Aquest esquema que no presenta cap VLAN es faria de manera anàloga a l'anterior, però sense configurar el bond. Agafaríem cada targeta virtual **Linux bridge** i l'enllacem a la targeta de sortida. L'esquema quedaria de la següent manera:

![Configuració de xarxes al proxmox](ConProxmox/prox46xxx.png)

:::caution
Un dels problemes que presenta aquesta configuració és saber quina targeta es quina, podem anar provant i veure quina està activa amb la ferramenta **ip** per a saber quina és quina. Podem anar desconectant els cables veure que apareix **state DOWN** i associar la connexió.
:::

```tcsh
root@cefirevalencia:~# ip link show enp4s0
5: enp4s0: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 state DOWN mode DEFAULT group default qlen 1000
``` 
:::note 
Tant en el **esquema 1** (el que usarem en este curs) com el **esquema 2** el nom de les targetes és el mateix (vmbrXX). Per tant la configuració de les targetes de xarxa en les VM serà exactament igual. 
:::


# Configuració de la xarxa en cada màquina virtual

Hem de recordar que cada servidor LliureX ha de tenir 3 targetes:

| Targeta | Característiques |
| -- | -- |
| Targeta externa | És la que es connectarà a la xarxa d'Aules |
| Targeta interna | La que dona servei als ordinadors de l'Aula o les classes |
| Targeta de replicació | Per a muntar el /net entre els servidors |

En el nostre cas recordem que les tenim configurades de la següent manera:

| Targeta | nom |
| -- | -- |
| Targeta externa | vmbr0 |
| Targeta interna | vmbr2, vmbr3, vmbr4, vmbr5 |
| Targeta de replicació | vmbr10 |

Per a configurar cada màquina virtual seleccionem la màquina i anem a les opcions de **Hardware**, fem click sobre **Add** i escollim **Network device**.

![Configuració de xarxa de VM](ConProxmox/prox24.png)

Com quan hem instal·lat la màquina virtual ja ens ha agafat la vmbr0, eixa la deixem com la externa. I configurem ja la interna.

![Configuració de targeta virtual](ConProxmox/prox25.png)

Aquest procediment l'hem de repetir en tots els servidors. Recorda que l'esquema de xarxa és el següent:

| IP | Servidor |
| -- | -- |
| 172.X.Y.254 | Servidor Maestro |
| 172.X.Y.253 | Servidor de Centro |
| 172.X.Y.252 | Servidor de Aula 1 |
| 172.X.Y.251 | Servidor de Aula 2 |
| 172.X.Y.250 | Servidor de Aula 3 |

## Targetes virtuals

:::warning
És important que ens assegurem abans d'inicialitzar el servidor quina targeta és quina, per a que no ens confonen. El servidor podria començar a donar DHCP a través de targeta connectada a la VLAN1 o router (depenent de l'esquema) i podria deixar sense servei a tot el centre.
:::

Podem comprovar quina és cada targeta amb el comandament ip fet al servidor i comparar les MAC.

![Configuració de xarxa de VM](ConProxmox/prox26.png)

## Inicialització servidors

Quan iniciem el servidor, en aquest cas el màster, escollim les següents opcions:

![Inicialitzar el servidor](ConProxmox/prox27.png)

:::warning
És molt important que habilites l'opció ***d'exportar*** el /net al servidor mestre.
:::

Un procediment extra que no ens ha d'oblidar en cap servidor és actualitzar-los sempre abans de fer res. I en el màster hem de configurar el lliurex mirror:

![Mirror](ConProxmox/prox29.png)

![Mirror](ConProxmox/prox30.png)

![Mirror](ConProxmox/prox31.png)

De manera similar inicialitzem els altres servidors:

![Inicialitzar el servidor](ConProxmox/prox32.png)

:::warning
És molt important que habilites l'opció ***munta*** el /net des del mestre.
:::

# Configuracions addicionals

## Arrancar les màquines virtuals quan inicia el servidor

És important que quan es reinicie l'hipervisor les màquines virtuals arranquen automàticament per a no tindre que connectar-se al proxmox per engegar-les una a una. Per a configurar aquesta opció seleccionarem una màquina virtual i seleccionarem l'opció de configuració **Options** i canviarem els paràmetres **Start at boot** a **Yes** i **Start/Shutdown order** a 1 en el cas del servidor mestre.

:::caution
És recomanable arrancar primer el mestre i deixar un temps per a que arranque i posteriorment arrancar els esclaus. Així, als servidors esclaus afegirem un temps a **Startup delay**.
:::

![Configuració d'orde d'arrancada](ConProxmox/prox33.png)

![Configuració d'orde d'arrancada](ConProxmox/prox34.png)

Al servidor de centre i esclau les opcions quedarien de la següent manera:

![Configuració d'orde d'arrancada al servidor de centre](ConProxmox/prox35.png)

![Configuració d'orde d'arrancada al servidor de l'Aula d'informàtica](ConProxmox/prox36.png)

## Muntatge de cabina externa (Opcional)

És possible que ens interesse l'opció d'una cabina externa. Té nombrosos avantatges, a l'espai de la cabina externa podem tindre emmagatzemat isos, discs durs de màquines virtuals, còpies de seguretat...

:::note 
El que s'explica en este punt no és per a aconseguir l'alta disponibilitat (HA) . És per a afegir un emmagatzemament comú al cluster on fer backups, emmagatzemar el disc d'alguna VM, isos, etc. Les cabines no entren dins de la dotació, per tant seria una adquisició pròpia del centre i no es tractarà en este curs com es configuren. 
:::

":::warning 
Hi ha la possibilitat d'emmagatzemar /net del servidor mestre en una cabina externa. Segons com es realitze pot donar problema amb les ACL dels arxius i no funciona. L'opció per a aconseguir açò és crear un segon disc virtual en el servidor mestre però emmagatzemar-ho en la cabina externa. Quan es realitza la instal·lació de la VM (en l'apartat de particionamiento de disc) s'indicaria que eixe segon disc s'usarà per a /net. Açò funciona perfectament ja que per a la VM és com si fóra un disc local. 

A més, per a fer açò és aconsellable que la cabina tinga unes característiques adequades. Es recomanaria com a mínim: 

* Possibilitat de crear un bond amb 4 targetes de xarxa, o targeta de 10G (faria falta un switch que ho suporte) 
* Almenys 4 discos durs per a muntar un RAID10 
* Trossege de disc SSD Amb estàs característiques es podria muntar inclús un sistema amb Alta disponibilitat. 
:::


Si el centre disposa d'una cabina funcionant, configurada i connectada en la xarxa del centre podem afegir-la al nostre **Datacenter** seleccionant-lo i anant a l'opció de **Storage**. Fem click sobre **Add** i escollim **NFS**.

![Configuració de cabina](ConProxmox/prox37.png)

I seleccionem les diferents opcions de configuració:

![Configuració de cabina](ConProxmox/prox38.png)

## Creació de backup (Opcional)

La creació de backups periòdics de les VM és molt aconsellable. En PROXMOX és molt fàcil fer backups de les VM i restaurar-los. Poden succeir imprevistos com desconfigurar un servidor per error, esborrar /net per error o qualsevol desastre que ens podem imaginar. En estos casos tindre una còpia de seguretat de les nostres VM és de gran utilitat.

:::note 
Una cabina de discos o NAS amb unes prestacions modestes seria prou per a realitzar estes tasques. També es podria usar un segon disc de l'hipervisor si no hem fet un RAID1.
:::


Per a configurar la còpia de seguretat seleccionem el datacenter, anem a l'opció de Backup i fem click sobre **Add**.

![Configuració de cabina](ConProxmox/prox39.png)

Ens apareixerà la següent finestra, hem de tenir en compte en quin lloc volem fer el backup (**Storage**). I seleccionem la/les màquines virtuals que volem fer còpia de seguretat, en un principi, en el nostre cas només caldria fer la còpia de seguretat del Màster, ja que és on es guarda el /net i LDAP. La còpia de seguretat queda programada per a una data determinada, en principi, en un centre, un dissabte a les 12 de la nit no hi ha cap usuari connectat.

![Configuració de la còpia de seguretat](ConProxmox/prox40.png)

També és pot fer una còpia de seguretat en qualsevol moment. Les còpies de seguretat porten temps, per tant no és recomanable fer-ho en hores on s'estiguen utilitzant els servidors.

![Creació de la còpia de seguretat](ConProxmox/prox41.png)

![Creació de la còpia de seguretat](ConProxmox/prox42.png)

Una vegada tenim la còpia de seguretat feta podem restaurar-la amb **Restore**.

:::caution
Quan es restaura la còpia de seguretat es crearà una nova màquina virtual amb les mateixes característiques que la màquina antiga i ens preguntarà en quin espai volem instal·lar la nova màquina. Hem d'anar amb compte de no tenir les dues màquines funcionant al mateix temps (després de restaurar-la) ja que crearà problemes de xarxa. També hem de recordar deshabilitar l'opció de **Start at boot**, sinó al reiniciar l'hipervisor arrancaran les dues màquines.
:::

![Restaurar la còpia de seguretat](ConProxmox/prox43.png)

![Restaurar la còpia de seguretat](ConProxmox/prox44.png)


# Bibliografia i referències

(@) https://es.wikipedia.org/wiki/VLAN


