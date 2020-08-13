#! /usr/bin/env sh

# Script used to generate release

mkdir -p dist
tar caf dist/hubtodate.tar.gz lib/ rules/ hubtodate META6.json
gpg --sign dist/hubtodate.tar.gz
mv dist/hubtodate.tar.gz.gpg dist/hubtodate.tar.gz
sha256sum dist/hubtodate.tar.gz > dist/sha256sums.txt
echo "done"
