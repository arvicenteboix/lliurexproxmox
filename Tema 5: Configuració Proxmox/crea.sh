#!/bin/bash
pandoc M5.md -o M5.pdf --from markdown+implicit_figures --template eisvogel --listings --filter pandoc-latex-environment --number-sections --toc
pandoc M5_es.md -o M5_es.pdf --from markdown+implicit_figures --template eisvogel --listings --filter pandoc-latex-environment --number-sections --toc

