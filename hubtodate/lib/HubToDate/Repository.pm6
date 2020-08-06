use HubToDate::Setting;
use HubToDate::GitHub;
use HubToDate::GitLab;
use HubToDate::Log;

package HubToDate::Repository {
  class Repository does Setting is export {
    our Str $name = "repository";

    method fetch --> List:D {
      # Wherever we should fetch the release
      # TODO: Support GitLab and BitBucket (and others)
      my $on = (%.settings{"on"} // "GitHub");
      my ($owner, $name) = %.settings{"owner", "name"};

      log VERBOSE, "Fetching $owner/$name on $on...";

      my $way = do given lc $on {
        # As of now, GitHub is the only way supported
        when "gitlab" { "HubToDate::GitLab"; }
        when "bitbucket" { "HubToDate::BitBucket" }
        default { "HubToDate::GitHub"; }
      }

      &::($way)::get-release(|@($owner, $name)), "$owner-$name";
    }
  }
}
