Creating your own rules
=======================

A rule doesn't yet exist for a repository? You can easily create your own. They are simple INI files with more functionality.

They can take any file extension, except `.ex` or `.example`, which are ignored by HubToDate, and are usually stored in `/usr/share/hubtodate/rules`.

Structure
---------

Rules work like INI files, meaning their structure should be of multiple key value pairs, down a header:

    [header]
    key = value

The four possible headers for a rule are repository, for any information related to the repository to install, such as the owner and name, release, which describes how to find, unpack and install a release, verification, which tells how to verify the downloaded archive with GPG or by checking sums, and optionally options, to change HubToDate's behavior per rule.

The value may be multiline, by specifying a backslash at the end of the line:

    [header]
    key = multiline \
            value
    otherkey = ...

The equal sign may also be replaced by a colon, meaning that: `key : value` works as well.

Types
-----

Each value has a type, either string (by default), integer, true, false, or nothing.

In case the value is only made of numbers, (e.g. 42) its type will be integer. If it contains a non-numeric character, its type will be string. (e.g. 42s)

In case the value is positive, such as "yes" or "true" ("yep" and "yeah" might also work), its type will be true. As opposite, negative values such as "no" or "false" (or "nope", "Nah", "0") will be of type false.

Last but not least, three dots ("...") will specify type nothing, meaning it has no value. You can also simply not write the key value pair.

Comments
--------

Lines starting by a hashtag ("#") or a semicolon (";") will be understood as comments and ignored. Same applies to comments after a value:

    # This is a comment
    key = value ; This is ignored!

The [repository] field
----------------------

The repository field may contain up to three values:

  * on - *(optional)* Tells where the repository should be fetched from. (e.g. GitHub)

  * owner - Person who owns the repository. (e.g. demostanis)

  * name - Name of the repository. (e.g. hubtodate)

Meaning that this is valid:

    [repository]
    owner = ogham
    name = exa

However, this is not:

    [repository]
    on = gitlab
    name = exa

Because, as of now, HubToDate doesn't search for repositories. You must explicitly tell who created the repository and how it is called.

The [release] field
-------------------

The release field describes how to find right release, (archive to install the software) unpack it if needed, and install it. It may contain these values:

  * match - A Raku regex to find the right archive. (e.g. hubtodate.tar.gz)

  * unpack - A shell command to unpack the archive. (e.g. tar xf <archive>)

  * install - A shell command to install the software. (e.g. pacman -U hubtodate.tar.gz)

  * root - Whetever the install command should be run as root. If not, it is run as "nobody" user.

To match the right archive: if its name is constant between releases (e.g. software-amd64.deb), you may just set this value to it. If, however, its name may change (e.g. software-1.1.1.deb), you will need to use a regex. An example to match a version: `'software-' \d+ % \. '.deb'` should match "software-1.0.deb", "software-14.0.22.deb", etc. For the unpack value, `\<archive\> ` is automatically replaced by the downloaded archive.

The [verification] field
------------------------

The verification field tells how to verify archive using a checksum, or with GPG. (no support yet) Currently supported algorithms are: (depending whetever your OS supports `\<algorithm\>sum ` command, which should be included in GNU coreutils)

  * md5

  * sha1

  * sha224

  * sha256

  * sha386

  * sha512

  * b2

Its value must be the filename where the checksums are. For example:

    [verification]
    b2sums = b2sums.txt

Should fetch b2sums.txt file from the releases page, and run `b2sum --check` with its contents.

The [options] field
-------------------

The options field changes HubToDate's behavior. There are currently no options as of now.

Examples
--------

You may find examples in the [GitHub repository](https://github.com/demostanis/hubtodate/tree/master/hubtodate/rules).
