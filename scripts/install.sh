#! /usr/bin/env sh

# The recommended way of installing HubToDate
# It should be run as root
# Basically, it installs modules, creates
# appropriate folders, copies default rules
# and sets adequate permissions

zef install --/test --force .
mkdir -p /usr/share/hubtodate
cp hubtodate /usr/bin
cp -rn rules /usr/share/hubtodate/rules
cp -n hubtodate.conf /etc
chmod 600 -R /usr/share/hubtodate
chmod 644 /etc/hubtodate.conf
hubtodate
