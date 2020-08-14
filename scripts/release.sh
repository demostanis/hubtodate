#! /usr/bin/env sh

# Script used to generate release

mkdir -p dist
tar caf dist/hubtodate.tar.gz lib/ rules/ hubtodate META6.json
cd dist && gpg --output hubtodate.tar.gz.sig --sign hubtodate.tar.gz
sha256sum hubtodate.tar.gz hubtodate.tar.gz.sig > sha256sums.txt
