use HubToDate::Setting;
use HubToDate::Log;
use WWW;

package HubToDate::Verification {
  class Verification does Setting is export {
    our $name = "verification";

    method check(:@stuff (Str $archive where *.IO.f, %repository)) {
      if %.settings{"sha256sums"} {
        my $file = $.settings{"sha256sums"};
        for %repository{"assets"}.kv -> $i, %asset {
          if %asset{"name"} ~~ / <$file> / {
            my $proc = Proc::Async.new: :w, "sha256sum", "--ignore-missing", "-c";

            react {
              whenever $proc.ready {
                log VERBOSE, "Checking sums...";
              }
              whenever $proc.stderr {
                log ERROR, "Error while checking sums: $_";
                exit 1;
              }
              whenever $proc.start: cwd => $archive.IO.dirname {
                log VERBOSE, "Archive matches its checksum!";
                done;
              }
              whenever $proc.write: get(%asset{"browser_download_url"}) {
                $proc.close-stdin;
              }
            }

            last;
          } elsif $i == %repository{"assets"}.elems - 1 {
            log WARN, "Couldn't find checksums file, skipping...";
          }
        }

        # TODO: add support for BSDs
        # which don't have sha256sum
      } else {
        log WARN, "Not verifying checksums, archive could be corrupted!";
      }

      if %.settings{"gpgkey"} {
        # NYI
      }

      $archive;
    }
  }
}
