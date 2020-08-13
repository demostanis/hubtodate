#! /usr/bin/env sh

# Script used to generate release

mkdir -p dist
tar caf dist/hubtodate.tar.gz lib/ rules/ hubtodate META6.json
cd dist && sha256sum hubtodate.tar.gz > sha256sums.txt
