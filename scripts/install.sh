#! /usr/bin/env sh

zef install --/test .
mkdir -p /usr/share/hubtodate
cp hubtodate/bin/hubtodate /usr/bin
cp -r hubtodate/rules /usr/share/hubtodate/rules
chmod 600 -R /usr/share/hubtodate
hubtodate
