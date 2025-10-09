#!/bin/bash
pandoc Activitat3.md -o Activitat3.pdf --from markdown+implicit_figures --template eisvogel --syntax-highlighting=idiomatic --filter pandoc-latex-environment --number-sections --toc

