package HubToDate::Parse {
  grammar Parser {
    token TOP { ^ <.eol>* <sections>* <.eol>* }
    token sections { <header> <keyval>* }

    rule header { ^^ '[' ~ ']' $<name>=<-[ \]\n ]>+ <.eol>* }
    rule keyval { $<key>=[\w+] <[:=]> <value> <.eol>* }

    token value { [ <string=normal-value>+ | <string=backslash> | <.newline> ]* }
    token newline { '\\' <[\h]>* <.eol>* }
    token backslash { \\ <?before \S> }
    regex normal-value { <-[#;\n\\]> }

    token eol { [ <[\h]>* <[;#]> \N* ] \n+ }
  }

  class Parser::Actions {
    method TOP($/) {
      my %hash = $<sections>».made;
      make %hash;
    }
    method sections($/) {
      make $<header><name>.Str => $<keyval>».made.hash;
    }
    method keyval($/) {
      make $<key>.Str => $<value>.defined ?? $<value>.made !! "";
    }
    method value($m) {
      given $m.trim.lc {
        when / ^ \d+ $ / { $m.make: $m.Int }
        when / ^ '...' $ / { $m.make: Nil }
        when / ^ [0|false|n|no|nope|nah] $ / { $m.make: False }
        when / ^ [1|true|y|ye|yes|yea|yep|yeah] $ / { $m.make: True }
        default { $m.make: $m.<string>.join("").trim }
      }
    }
  }

  multi sub parse(Str $text) is export {
    Parser.parse($text,
      actions => Parser::Actions.new).made;
  }

  multi sub parse(IO::Path $file) is export {
    Parser.parse($file.slurp,
      actions => Parser::Actions.new).made;
  }
}
