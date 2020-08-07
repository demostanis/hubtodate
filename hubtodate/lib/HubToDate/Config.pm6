use HubToDate::Parse;
use HubToDate::Log;

package HubToDate::Config {
  # We create a configuration file at the specified path
  # if it doesn't exit, or just read it normally
  sub read-config(Str:D $path where { $_.IO.f or
    $_.IO.spurt: "# Configuration file was not found, so we created it for you" }
    = "/etc/hubtodate.conf" --> Hash:D) is export {
    my %config = parse($path.IO, { log ERROR, "Failed to parse configuration file!"; });

    # If any setting is not in the configuration, set it
    # to an empty hash. ∉ is U+2209
    for <paths other> {
      %config{$_} = {} if $_ ∉ %config.keys.cache;
    }

    %config;
  }

  our %config is export = read-config;
}
