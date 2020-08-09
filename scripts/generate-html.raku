#! /usr/bin/env raku

# Perhaps we should make a fork of Pod::To::HTML
# in the future? Something which doesn't make
# every <a> go to the top of the document...

use Pod::To::HTML;

my $folder = "./templates";
dir $folder or die "Could not find templates...";

for run(<find -name *.pod6>, :out).out.lines {
  my $file = .IO;
  my $filename = $file
    .basename.IO
    .extension: "";
  my $dest = ($filename eq "index"
    ?? '' !! "html/") ~ "$filename.html";

  $dest.IO.spurt: render($file,
    css => "$folder/css/stylesheet.css".IO.slurp,
    template => $folder,
    code => True
  );
}
