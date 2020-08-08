use HubToDate::Setting;
use HubToDate::Config;
use HubToDate::GitHub;
use HubToDate::GitLab;
use HubToDate::Log;

package HubToDate::Repository {
  our $PKGS_DIR = %config{"paths"}{"pkgs"} // "/usr/share/hubtodate/pkgs/";

  class Repository does Setting is export {
    our $name = "repository";

    method fetch returns Promise:D {
      my Promise $p .= new;

      # Wherever we should fetch the release
      # TODO: Support GitLab and BitBucket (and others)
      if %.settings{"on"} andthen .lc ∉ <github gitlab bitbucket> {
        log WARN, "Wrong value for 'on', falling back to GitHub...";
      }

      my $on = (%.settings{"on"} // "github");
      my ($owner, $name) = %.settings{"owner", "name"};

      log VERBOSE, "Fetching $owner/$name on $on...";

      my $way = do given lc $on {
        # As of now, GitHub is the only way supported
        when "gitlab" { "HubToDate::GitLab"; }
        when "bitbucket" { "HubToDate::BitBucket" }
        default { "HubToDate::GitHub"; }
      }

      my $to = "$owner-$name";
      my %release = &::($way)::get-release(|@($owner, $name));
      if %release{"tag_name"} eq "$PKGS_DIR/$to/lastrelease".IO.slurp {
        $p.break: "Repository is up-to-date, no need to update";
      } else {
        $p.keep(@(%release, $to));
      }
      $p;
    }
  }
}
