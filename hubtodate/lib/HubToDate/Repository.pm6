use HubToDate::Setting;
use HubToDate::GitHub;
use HubToDate::GitLab;
use HubToDate::Log;

package HubToDate::Repository {
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

      $p.keep(@(&::($way)::get-release(|@($owner, $name)), "$owner-$name"));
      $p;
    }
  }
}
