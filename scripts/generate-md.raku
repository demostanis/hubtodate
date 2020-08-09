#! /usr/bin/env raku

use Pod::To::Markdown;

# In case it doesn't exist
mkdir "dist";

for run(<find -name *.pod6>, :out).out.lines {
  my $file = .IO;
  my $filename = $file
    .basename.IO
    .extension("")
    .Str;
  my $dist = $filename eq "index"
    ?? "$filename.md"
    !! "dist/$filename.md";

  say "Processing file $file...";

  $dist.IO.spurt:
    (run «$*EXECUTABLE --doc=Markdown "$file"», :out).out.lines.join: $?NL;
}
