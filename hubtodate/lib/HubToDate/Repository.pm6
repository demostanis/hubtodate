use HubToDate::Setting;
use HubToDate::GitHub;
use HubToDate::GitLab;
use HubToDate::Log;

package HubToDate::Repository {
  class Repository does Setting is export {
    our $name = "repository";

    method fetch(:$options) {
      my $on = (%.settings{"on"} // "GitHub");
      my ($owner, $name) = %.settings{"owner", "name"};

      log VERBOSE, "Fetching $owner/$name on $on...";

      my $way = do given lc $on {
        when "gitlab" { "HubToDate::GitLab"; }
        when "bitbucket" { "HubToDate::BitBucket" }
        default { "HubToDate::GitHub"; }
      }

      &::($way)::get-release(|@($owner, $name)), "$owner-$name";
    }
  }
}
