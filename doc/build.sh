#!/bin/bash

rm -rf build/*
mkdir -p build
for i in state_diagrams.tex; do
  lualatex -interaction=batchmode --output-directory=build $i
done
