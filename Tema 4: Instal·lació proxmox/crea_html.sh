#!/bin/bash
pandoc M4.md -o index.html --from markdown+implicit_figures -c aqua.css --template ./plantilla.html --listings --filter pandoc-latex-environment --number-sections --toc --toc-depth 3
pandoc M4_es.md -o index_es.html --from markdown+implicit_figures -c aqua.css --template ./plantilla.html --listings --filter pandoc-latex-environment --number-sections --toc --toc-depth 3
