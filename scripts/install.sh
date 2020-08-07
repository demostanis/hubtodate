#! /usr/bin/env sh

# The recommended way of installing HubToDate
# It should be run as root
# Basically, it installs modules, creates
# appropriate folders, copies default rules
# and sets adequate permissions

zef install --/test --force .
mkdir -p /usr/share/hubtodate
cp -n hubtodate/bin/hubtodate /usr/bin
cp -rn hubtodate/rules /usr/share/hubtodate/rules
cp -n hubtodate/etc/hubtodate.conf /etc
chmod 600 -R /usr/share/hubtodate
chmod 600 /etc/hubtodate.conf
hubtodate
