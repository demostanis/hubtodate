use HubToDate::Setting;
use HubToDate::Log;
use GPGME;
use WWW;

package HubToDate::Verification {
  class Verification does Setting is export {
    our $name = "verification"; # Field name

    method check(@ (Str:D $archive where *.IO.f, %repository), %options? --> Promise:D) {
      # In case sha256sums setting was specified,
      # download the checksums file and verify files
      # by spawning a `sha256sum` process

      my Promise $p .= new;

      if my $method = %.settings.first(*.key eq "md5sums"|
                                                  "sha1sums"|
                                                  "sha224sums"|
                                                  "sha256sums"|
                                                  "sha386sums"|
                                                  "sha512sums"|
                                                  "b2sums") {
        my $file = $method.value;
        for %repository{"assets"}.kv -> $i, %asset {
          if %asset{"name"} ~~ / <$file> / {
            log VERBOSE, "Checking {$method.key}...";

            # The checksums file may include checksums for not-downloaded files
            my Proc::Async $proc .= new: :w, $method.key.substr(0, *-1), "--ignore-missing", "--check";

            react {
              # Whenever there was an error...
              whenever $proc.stderr {
                log ERROR, "Error while checking sums: $_";
              }
              # Whenever the process is done...
              # (true, this can cause confusion)
              whenever $proc.start: cwd => $archive.IO.dirname {
                log VERBOSE, "Archive matches its checksum!";
                done;
              }
              # Whenever we're done writting the fetched checksums
              # to the standard output
              # TODO: `browser_download_url` is GitHub dependent, this should be changed to support GitLab and others
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
        # (it has another name)
      } else {
        log WARN, "Not verifying checksums, archive could be corrupted!";
      }

      if my $file = %.settings{"signature"} {
        for %repository{"assets"}.kv -> $i, %asset {
          if %asset{"name"} ~~ / <$file> / {
            # Dirty way of getting user's .gnupg folder
            # One can specify --gpg-user=... to the CLI
            # to change the GPG user

            my $homedir;
            if $_ = %options{"gpg-user"} {
              $homedir = shell("echo ~$_}", :out).out.get ~ "/.gnupg";
            } elsif %*ENV{"SUDO_USER"} && %*ENV{"SUDO_USER"} ne "root" &&
              %*ENV{"SUDO_USER"} ~~ / ^ <[a..zA..Z0..9\-_]>+ $ / {
              $homedir = shell("echo ~{%*ENV{'SUDO_USER'}}", :out).out.get ~ "/.gnupg";
            } else {
              $homedir = "/root/.gnupg";
            }

            log VERBOSE, "Verifying archive's GPG signature...";

            # Verifies downloaded GPG signature
            # If it throws an Failure, it means that archive
            # is not signed. If it doesn't, check if it's valid
            my $gpg = GPGME.new(:$homedir, :armor);
            try {
              CATCH {
                default {
                  log WARN, "Archive isn't signed...";
                }
              }

              my $sig-file = "{$archive.IO.dirname}/%asset{'name'}";
              $sig-file.IO.spurt: get(%asset{"browser_download_url"});
              $gpg.verify: $sig-file.IO;
            } && do for $gpg.signatures -> $sig {
              if $sig.summary.isset("valid") {
                log VERBOSE, "Archive was signed by $sig.fpr(), trusted";
              } else {
                log ERROR, "Key $sig.fpr() isn't trusted! ($sig.summary())";
              }
            }

            last;
          }
        }
      }

      $p.keep: $archive;
      $p;
    }
  }
}
