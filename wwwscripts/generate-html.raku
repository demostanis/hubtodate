#! /usr/bin/env raku

use Pod::To::HTML;

for dir ".", test => *.ends-with(".pod6") {
  my $name = .basename.IO.extension("").Str;
  ($name ~ ".html").IO.spurt: render(
    $_,
    title => $name.Str eq "index" ?? "HubToDate website" !! $name ~ " | HubToDate",
    subtitle => "HubToDate website",
    lang => "en"
  )
}
