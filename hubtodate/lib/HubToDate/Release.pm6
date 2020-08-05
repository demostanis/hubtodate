use UNIX::Privileges :ALL;
use HubToDate::Setting;
use HubToDate::Log;
use Colorizable;
use WWW;

package HubToDate::Release {
  our $PKG_DIR = "/usr/share/hubtodate/pkgs/";

  sub drop-privileges {
    drop("nobody");
  }

  class Release does Setting is export {
    our $name = "release";

    method download(:@stuff (%repository, $to), :$options) {
      my $match = $.settings{"match"};
      for %repository{"assets"}.kv -> $i, %asset {
        if %asset{"name"} ~~ / <$match> / {
          log VERBOSE, "Found archive: %asset{'name'}";
          log VERBOSE, "Downloading...";

          my $supports-wget = do given run(<wget --version>, :out, :err) {
            when .exitcode == 0 and
              .out.get ~~ / "GNU Wget " (\d)'.' <?{ $0.Int > 0 }> (\d+)'.' <?{ $1.Int > 15 }> / { True }

            default { False }
          }

          mkdir "$PKG_DIR/$to/%repository{'tag_name'}", 0o600;
          "$PKG_DIR/$to/lastrelease".IO.spurt: %repository{'tag_name'};

          # To get a motherfucking progress bar
          if $supports-wget {
            my @cmd = «wget --quiet -O"$PKG_DIR/$to/%repository{'tag_name'}/%asset{'name'}" --show-progress "%asset{'browser_download_url'}"»;
            my $proc = run @cmd;
            if $proc.exitcode {
              log ERROR, "An error occured while trying to download archive with wget: $proc.err";
              exit 1;
            }
          } else {
            "$PKG_DIR/$to/%repository{'tag_name'}/%asset{'name'}".IO.spurt: get(%asset{"browser_download_url"});
          }

          log VERBOSE, "Done!";
          return ("$PKG_DIR/$to/%repository{'tag_name'}/%asset{'name'}",
                  %repository);
        } elsif $i == %repository{"assets"}.elems - 1 {
          log ERROR, "Could't find archive, available ones are:
{%repository{"assets"}.values.map('   ' ~ *{'name'} ~ $?NL)}";
        }
      }
    }

    method unpack(Str :$archive where *.IO.f, :$options) {
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

    method install(Str :$folder where *.IO.d, :$options) {
      log VERBOSE, "Installing using command: ";
      say .white with "      %.settings{'install'}" but Colorizable;

      my $proc = shell $.settings{'install'},
        cwd => $folder;

      log ERROR, "An error occured while trying to install: $proc.err" if $proc.exitcode;
      log VERBOSE, "Done!";
    }
  }
}
