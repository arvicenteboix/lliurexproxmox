---
# Front matter
# Metainformació del document
title: "Model de centre amb Virtualbox"
author: [Alfredo Rafael Vicente Boix i Javier Estellés Dasi]
date: "05-05-2024"
subject: "Proxmox"
keywords: [Xarxa, Instal·lació]
subtitle: "ACTIVITAT"

lang: ca
page-background: img/bg.png
titlepage: true
# portada
titlepage-rule-height: 2
titlepage-rule-color: AA0000
titlepage-text-color: AA0000
titlepage-background: ../portades/U2.png

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

Aquest document està subjecte a una llicència creative commons que permet la seua difusió i ús comercial reconeixent sempre l'autoria del seu creador. Aquest document es troba per a ser modificat al següent repositori de github:
<!-- CANVIAR L'ENLLAÇ -->
[https://github.com/arvicenteboix/lliurexproxmox](https://github.com/arvicenteboix/lliurexproxmox)
\newpage


# Valencià

## Activitat

L’activitat que vos proposem és crear un model de centre des de 0. Vos hem deixat un vídeo amb tot el procés (amb alguna errada que ens ha passat i com ho hem solventat). Compte!!! El vídeo no té audio, és només el procediment que s’ha de seguir.

## Característiques de l’ordinador

L’ordinador que s’ha utilitzat té les següents característiques:

* Sistema Operatiu: arch linux, distro Manjaro
* Ryzen 5
* 8GB de RAM
* 256 GB disc dur ssd m2

Heu d’anar amb compte amb les característiques que poseu a cada màquina, per a fer la instal·lació de cadascuna he posat molts recursos per a fer-ho més despresa, però després he baixat els recursos a 1,5 GB de RAM i 1 processador cada màquina.

## Procediment de l’activitat

1. Descarregar el *appliance* de màquines de Virtualbox i importar-les.
2. Canviar les característiques que s'adapten a les vostres màquines
3. Inicialitzat servidor mestre
4. inicialitzar servidor esclau
5. Crear usuari amb llum (prova)
6. Instal·lar client
7. Inicialitzar el client amb l’usuari prova.

:::warning
Les màquines estan inicializades i funcionen. Heu de canviar el nom de cada màquina a CODI_DE_CETRE+{MAS,CEN,AU1 o AU2} per a que comprovar que heu fet el canvi.
:::

## Aconseguir Apte en l’activitat

L’activitat es considerarà APTA entregant un full en format pdf amb les següents captures de pantalla:

* Característiques de cada màquina
* Els dos servidors funcionant
* Dos servidors (Un mestre i un esclau) i el client funcionant
* Captura de inicialització (zero-server-wizard) d’un dels servidors
* Captura d'una ip a en la terminal d'un dels servidors

```bash
ip a
```

## Exemple de captures de pantalla

![Captura 1](img/-015.png)

![Captura 2](img/-019.png)

![Captura 3](img/-020.png)

![Captura 4](img/-024.png)

![Captura 5](img/-025.png)

![Captura 6](img/-029.png)

![Captura 7](img/-030.png){ width=50% }






# Castellano

## Actividad

La actividad que os proponemos es crear un modelo de centro desde cero. Os hemos dejado un vídeo con todo el proceso (con algún error que nos ha ocurrido y cómo lo hemos solucionado). ¡Cuidado! El vídeo no tiene audio, es solo el procedimiento que se debe seguir.

## Características del ordenador

El ordenador que se ha utilizado tiene las siguientes características:

* Sistema Operativo: arch linux, distro Manjaro
* Ryzen 5
* 8GB de RAM
* 256 GB disco duro ssd m2

Deben tener cuidado con las características que ponen en cada máquina, para hacer la instalación de cada una he puesto muchos recursos para hacerlo más rápido, pero luego he bajado los recursos a 1,5 GB de RAM y 1 procesador cada máquina.

## Procedimiento de la actividad

1. Descargar el *appliance* de máquinas de Virtualbox e importarlas.
2. Cambiar las características que se adapten a sus máquinas.
3. Inicializar servidor maestro.
4. Inicializar servidor esclavo.
5. Crear usuario con Llum (prueba).
6. Instalar cliente.
7. Inicializar el cliente con el usuario prueba.

:::warning
Las máquinas están inicializadas y funcionan. Deben cambiar el nombre de cada máquina a CODI_DE_CETRE+{MAS,CEN,AU1 o AU2} para comprobar que han hecho el cambio.
:::

## Conseguir Apto en la actividad

La actividad se considerará APTA entregando un documento en formato pdf con las siguientes capturas de pantalla:

* Características de cada máquina.
* Los dos servidores funcionando.
* Dos servidores (uno maestro y uno esclavo) y el cliente funcionando.
* Captura de inicialización (zero-server-wizard) de uno de los servidores.
* Captura de una ip en la terminal de uno de los servidores.

```bash
ip a
```
## Ejemplo de capturas de pantalla

![Captura 1](img/-015.png)

![Captura 2](img/-019.png)

![Captura 3](img/-020.png)

![Captura 4](img/-024.png)

![Captura 5](img/-025.png)

![Captura 6](img/-029.png)

![Captura 7](img/-030.png){ width=50% }