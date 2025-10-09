#!/bin/bash
pandoc Activitat2.md -o Activitat2.pdf --from markdown+implicit_figures --template eisvogel --syntax-highlighting=idiomatic --filter pandoc-latex-environment --number-sections --toc

