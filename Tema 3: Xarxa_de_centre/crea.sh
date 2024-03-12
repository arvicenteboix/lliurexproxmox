#!/bin/bash
pandoc Xarxa.md -o Xarxa.pdf --from markdown+implicit_figures --template eisvogel --listings --filter pandoc-latex-environment --number-sections --toc
