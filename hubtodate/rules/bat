; This file is a working example to install 'bat'

; Settings for the GitHub repository
; such as its owner and name
[repository]
on = github ; That's the default, perhaps we will support GitLab one day
owner = sharkdp
name = bat


; Settings related to the
; installation of a release
[release]
match = 'bat_' (\d+'.'?)+ '_amd64.deb' ; Regular expression to match a new release
                                       ; Note that this is a Raku one, and that you
                                       ; mustn't surround it with backslashes

unpack = ... ; Command to execute in order to unpack
             ; the newly downloaded archive, such as
             ; tar or unzip. It is not needed in this
             ; case as the release is a .deb file

install = dpkg -i *.deb && \    ; Command to install the package
    echo "bat was installed!!!" ; Here we use dpkg, the Debian's
                                ; package manager

root = yes ; Whetever or not root is required


; Settings for checksum verification
; and GPG signature validation
[verification]
sha256sums = checksums.txt ; A file containing sha256 checksums
                           ; Can also be a regular expression
gpgkey = ...


; Some options to manipulate
; HubToDate's behavior
[options]
silent = no
ignoreinvalidgpgkey = nah ; Dangerous if set to a positive value!
