#!/bin/bash
pandoc ClusteriHA.md -o ClusteriHA.pdf --from markdown+implicit_figures --template eisvogel --listings --filter pandoc-latex-environment --number-sections --toc
