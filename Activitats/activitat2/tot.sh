#!/bin/bash
./crea.sh
./crea_html.sh
# zip the files aqua.css index.html and the folders img i rsc
zip -r M2.zip index.html aqua.css img rsc
zip -r M2_es.zip index_es.html aqua.css img rsc