use WWW;
use HubToDate::Log;

# Actually, for now, it is pretty useless
# as many of the code follows GitHub's way
# without using this package

package HubToDate::GitHub {
  my $api-url = "https://api.github.com";

  our sub get-release(Str $owner, Str $name) {
    jget("$api-url/repos/$owner/$name/releases/latest") orelse
      log ERROR, "Failed to fetch: $_";
  }
}
