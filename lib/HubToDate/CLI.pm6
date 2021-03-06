use HubToDate::Rule;
use HubToDate::Log;
use HubToDate::Config;

package HubToDate::CLI {
  our @RULES_DIRS = [%config{"paths"}{"rules"} or "/usr/share/hubtodate/rules/"];

  # The MAIN subroutine, which gets executed
  # when the `hubtodate` executable is ran
  # It's a multi as there may have multiple
  # commands in the future (something like
  # `hubtodate check` to check updates
  # without updating?)
  multi MAIN(
    Str :$rules-dir?,    #= Specify a custom rules directory
    Str :$gpg-user?      #= Specify user to use to verify with GPG
  ) is export {
    # The program requires root, as it needs to access the root-owned
    # rules direcotry, and some software will require root to install
    # (if not, `root = no` in a rule file will drop privileges)
    log ERROR, "This program does not work without root." unless $*USER == 0;

    # The user can specify another custom rules directory
    @RULES_DIRS.prepend($rules-dir) if $rules-dir.defined;

    # For each rule directory, if the path isn't absolute,
    # make it, and then check if it exists
    for @RULES_DIRS -> $rule-dir where {
      { ($_ = "$*CWD/{$_.substr(2)}" if $_.starts-with("./")) } && $_.IO.r ||
      log ERROR, "Rules directory does not exist: $_" } {

      # Check if the folder's permissions aren't restrictive enough
      # It checks the two last digits (same group and others permissions)
      # whetever they are greater than 4 (more than readable)
      if $rule-dir.IO.mode.comb[2..3].any > 4 {
        log WARN, "Insecure permissions found for $rule-dir, this may be a security risk";
      }

      # For each rule in the directory,
      # check if it's not an example file (not
      # ending in .ex or .example) ...
      for dir $rule-dir, test =>
        { "$rule-dir/$_".IO.f && !$_.ends-with(".ex"|".exx"|".example") }
        -> $rule-file {
        # ... and process it
        my Rule $rule .= new(file => $rule-file,
          options => %(:$gpg-user,));
      }
    }
  }

  # Prints version using
  # zef package manager
  multi MAIN(
    "version"
  ) {
    my $proc = shell "zef list --installed 2>/dev/null | grep hubtodate", :out;
    my $line = $proc.out.lines.first: :end;

    $line ~~ / 'ver<' (\d+ % '.') '>' /;
    say "This is HubToDate version " ~ $0;
  }
}
