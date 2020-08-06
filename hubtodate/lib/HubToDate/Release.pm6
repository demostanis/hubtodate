use UNIX::Privileges :ALL;
use HubToDate::Setting;
use HubToDate::Log;
use Colorizable;
use WWW;

package HubToDate::Release {
  # This should be read from [paths] in the configuration file
  our $PKG_DIR = "/usr/share/hubtodate/pkgs/";

  class Release does Setting is export {
    our $name = "release";

    method download(@ (Hash:D %repository, Str:D $to)) {
      my $match = $.settings{"match"};
      for %repository{"assets"}.kv -> $i, %asset {
        # We check if the asset's name matches the user-provided regex
        if %asset{"name"} ~~ / <$match> / {
          log VERBOSE, "Found archive: %asset{'name'}";
          log VERBOSE, "Downloading...";

          # We check if wget is at the right version (>= 1.16)
          # as versions before do not support --show-progress
          my $supports-wget = do given run(<wget --version>, :out, :err) {
            when .exitcode == 0 and
              .out.get ~~ / "GNU Wget " (\d)'.' <?{ $0.Int > 0 }> (\d+)'.' <?{ $1.Int > 15 }> / { True }

            default { False }
          }

          mkdir "$PKG_DIR/$to/%repository{'tag_name'}", 0o600;
          "$PKG_DIR/$to/lastrelease".IO.spurt: %repository{'tag_name'};
          # TODO: Check using this file if the repository should really be updated

          # To get a motherfucking progress bar
          if $supports-wget {
            # This piece of code isn't prone to shell escape attacks,
            # `run` will execute `wget` executable, not a shell
            my @cmd = «wget --quiet -O"$PKG_DIR/$to/%repository{'tag_name'}/%asset{'name'}" --show-progress "%asset{'browser_download_url'}"»;
            my $proc = run @cmd;
            if $proc.exitcode { # If the exit code doesn't mean success (isn't 0)
              log ERROR, "An error occured while trying to download archive with wget: $proc.err";
            }
          } else {
            # If wget isn't supported or installed, fallback to the `get`
            # subroutine provided by WWW module
            "$PKG_DIR/$to/%repository{'tag_name'}/%asset{'name'}".IO.spurt: get(%asset{"browser_download_url"});
          }

          log VERBOSE, "Done!";
          return ("$PKG_DIR/$to/%repository{'tag_name'}/%asset{'name'}",
                  %repository);
        } elsif $i == %repository{"assets"}.elems - 1 {
          # In case we've finished looping through all assets
          # and that none matched user-provided regex, show
          # an error message with available assets
          log ERROR, "Could't find archive, available ones are:
{%repository{"assets"}.values.map('   ' ~ *{'name'} ~ $?NL)}";
        }
      }
    }

    method unpack(Str:D :$archive where *.IO.f) {
      if %.settings{"unpack"}.defined && %.settings{"unpack"} ne "..." {
        log VERBOSE, "Unpacking archive using command: ";
        say .white with "      %.settings{'unpack'}" but Colorizable;

        my $proc = shell "{S/'<archive>'/$archive/ with $.settings{'unpack'}}",
          cwd => $archive.IO.dirname;

        log ERROR, "An error occured while trying to unpack archive: $proc.err" if $proc.exitcode;
        log VERBOSE, "Done!";
      }
      $archive.IO.dirname;
    }

    method install(Str:D :$folder where *.IO.d) {
      # We install the software using user-provided's command.
      # We perhaps should refuse if the directory folder has
      # unrestrictive permissions? Or check if standard output
      # is a tty, inform the user permissions suck so that he
      # has the time to cancel, and the opposite in case it's
      # not a tty? (e.g. inside a crontab)

      log VERBOSE, "Installing using command: ";
      say .white with "      %.settings{'install'}" but Colorizable;

      my $proc = shell $.settings{'install'},
        cwd => $folder;

      log ERROR, "An error occured while trying to install: $proc.err" if $proc.exitcode;
      log VERBOSE, "Done!";
    }
  }
}
