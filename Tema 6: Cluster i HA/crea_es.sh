#!/bin/bash
pandoc ClusteriHA_es.md -o ClusteriHA_es.pdf --from markdown+implicit_figures --template eisvogel --listings --filter pandoc-latex-environment --number-sections --toc
