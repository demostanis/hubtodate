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
