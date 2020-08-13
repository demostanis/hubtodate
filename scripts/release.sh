#! /usr/bin/env sh

# Script used to generate release
# TODO: Sign archives with GPG

mkdir -p dist
tar caf dist/hubtodate.tar.gz lib/ rules/ hubtodate META6.json
sha256sum dist/hubtodate.tar.gz > dist/sha256sums.txt
echo "done"
