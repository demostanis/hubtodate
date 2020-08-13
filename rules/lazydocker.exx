; Another working example to install 'lazydocker'
; It is made as short as possible, if you want a
; more explained one, you should take a look at
; the one for 'bat'

[repository]
owner = jesseduffield
name = lazydocker

[release]
match = 'lazydocker_' \d+ % '.' '_Linux_x86_64.tar.gz'
unpack = tar xzf <archive> lazydocker
install = mv -f lazydocker /usr/bin
root = yes

[verification]
sha256sums = checksums.txt
