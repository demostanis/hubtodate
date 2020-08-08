# HubToDate
### Automatically fetches and updates repositories from GitHub
-----------

#### This software is still in beta version, beware when using!

## What does it do?
This software basically fetches and updates repositories from GitHub
with the help of user pre-defined rules (or example ones in ./hubtodate/rules)
stored in /usr/share/hubtodate. It is written in Raku.
For now there may have bugs and missing features, the code isn't very well
written but a rewrite is planned.

## Why the fuck would I want that? I use Arch btw and with AUR I have all software I want
Many distributions lack some software which can be found on GitHub, most of
the time because it is not popular enough. You have the choice to install
the binaries at the risk of keeping outdated software on your computer...
OR to use HubToDate.

## How can it be installed?
Make sure you have Rakudo and Zef installed.
There's an installer in ./scripts/install.sh, which needs to be run as root.
Otherwise, you can add ./hubtodate/bin to your $PATH, and write some rules inside
/usr/share/hubtodate/rules.
It can also be ran inside Docker. (pretty useless for a normal user, it was done
initially for testing purposes)

## Oh this seems nice, how can I contribute?
A feature is missing? (very probably) There is some annoying bug?
Pull Requests are open to everyone! Simply write some code, open a
Pull Request, and maintainers will check it as fast as they can!
You don't know how to write code? Issues are open too, you can
open one if you have any problem.

## You suck at coding
I am new to Raku, and still in a learning phase.

#### Licensed under BSD-3-Clause, as you can see in LICENSE
#### Copyright 2020, demostanis worlds
