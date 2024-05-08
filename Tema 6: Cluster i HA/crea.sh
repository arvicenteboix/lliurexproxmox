#!/bin/bash
pandoc M6.md -o M6.pdf --from markdown+implicit_figures --template eisvogel --listings --filter pandoc-latex-environment --number-sections --toc
pandoc M6_es.md -o M6_es.pdf --from markdown+implicit_figures --template eisvogel --listings --filter pandoc-latex-environment --number-sections --toc

