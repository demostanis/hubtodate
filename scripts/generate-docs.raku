#! /usr/bin/env raku

use Pod::To::HTML;

my $docs-dir = "docs/";
for dir $docs-dir, test => *.ends-with(".pod6") {
  ($docs-dir ~ "html/" ~ .basename.IO.extension: "" ~ "html").IO.spurt: render(
    $_,
    title => .basename.IO.extension("").Str,
    subtitle => "HubToDate docs",
    lang => "en"
  )
}
