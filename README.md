# HubToDate

## What does it do?
This software basically fetches and updates repositories from GitHub
with the help of user pre-defined rules (or example ones in `./hubtodate/rules`)
stored in `/usr/share/hubtodate`. It is written in Raku.

## Why would I want that? I use Arch and with AUR... *bla bla bla*
Many distributions lack some software which can be found on GitHub, most of
the time because they are not popular enough. You have the choice to install
the binaries at the risk of keeping outdated software on your computer...
OR to use **HubToDate**.

## How can it be installed?
Make sure you have **Rakudo** and **Zef** installed.
There's an installer in `./scripts/install.sh`, which needs to be run as `root`:
```sh
git clone https://github.com/demostanis/hubtodate.git /tmp/hubtodate && \
  cd /tmp/hubtodate && \
  sudo sh ./scripts/install.sh && \
  cd - >/dev/null && \
  rm -rf /tmp/hubtodate
```
(Note: For this script to run correctly, `git` and `curl` are required, as well as
not having `/tmp` mounted with `noexec`)
Otherwise, you can add `./hubtodate/bin` to your `$PATH`, and write some rules inside
`/usr/share/hubtodate/rules`. It can also run inside Docker for testing purposes, which
is pretty useless for a normal user.

## This seems nice, how do I contribute?
A feature is missing? There is a bug?
Pull requests are **open to everyone**! Simply write some code, open a
Pull request, and maintainers will check it as fast as they can!
You don't know how to write code? Issues are open too, you can
open one if you have any problem.

## Your code isn't that good
I am new to Raku, and still in a learning phase.

## Warning
This software is still in BETA. Beware when using!
Also, it only has been tested on Linux.

## License
**HubToDate** is licensed under **BSD-3-Clause**.
Take a look at `LICENSE` file.

## Author
Copyright 2020, demostanis worlds
