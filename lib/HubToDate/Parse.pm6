# The main parser for configuration file (/etc/hubtodate.conf)
# and rules. I got many help from moritz and his incredible
# book about regexes: https://www.apress.com/us/book/9781484232279

package HubToDate::Parse {
  grammar Parser {
    # File contains zero or more sections,
    # which consists of a header and multiple
    # key = value pairs
    token TOP { ^ <.eol>* <sections>* <.eol>* }
    token sections { <header> <keyval>* }

    # Capture to $<name> anything but ] or \n between [ ]
    rule header { ^^ '[' ~ ']' $<name>=<-[ \]\n ]>+ <.eol>* }
    # Capture to $<key> any word followed by either a = or : and a <value>
    rule keyval { $<key>=[\w+] <[:=]> <value> <.eol>* }

    # Capture to $<string> a normal value (anything but new lines and comments)
    # , a backslash or a new line, thus capturing multiline \
    #                                               values which \
    #                                               uses backslashes
    token value { [ <string=normal-value>+ | <string=backslash> | <.newline> ]* }
    token newline { '\\' <[\h]>* <.eol>* }
    token backslash { \\ <?before \S> }
    regex normal-value { <-[#;\n\\]> }

    # Any amount of newlines and comments (; or #)
    token eol { [ <[\h]>* <[;#]> \N* ]* \n+ }
  }

  class Parser::Actions {
    method TOP($/) {
      # Return an empty hash in case there are no sections
      if !$<sections>.elems {
        make %(empty => True);
      } else {
        my %hash = $<sections>».made;
        make %hash;
      }
    }
    method sections($/) {
      make $<header><name>.Str => $<keyval>».made.hash;
    }
    method keyval($/) {
      make $<key>.Str => $<value>.defined ?? $<value>.made !! "";
    }
    # We are checking the value and transforming it
    method value(Match:D $m) {
      given $m.trim.lc {
        when / ^ \d+ $ / { $m.make: $m.Int } # Any integer
        when / ^ '...' $ / { $m.make: Nil } # Three dots means that there's no value
        when / ^ [0|false|n|no|nope|nah] $ / { $m.make: False } # Negative values, feel free to add your favorite ones
        when / ^ [1|true|y|ye|yes|yea|yep|yeah] $ / { $m.make: True } # Positive values
        # Only return $<string>, we don't want the newlines
        default { $m.make: $m.<string>.join("").trim }
      }
    }
  }

  # In case the input is text...
  multi sub parse(Str:D $text, &error) is export {
    Parser.parse($text,
      actions => Parser::Actions.new).made
      or error;
  }

  # ... and in case the input is a file
  multi sub parse(IO::Path:D $file, &error) is export {
    Parser.parse($file.slurp,
      actions => Parser::Actions.new).made
      or error;
  }
}
