use HubToDate::Rule;
use HubToDate::Log;

package HubToDate::CLI {
  our @RULES_DIRS = </usr/share/hubtodate/rules/>;

  multi MAIN(
    Str :$rules-dir?,    #= Specify a custom rules directory
    Bool :$no-warnings?  #= Disable any warning
  ) is export {
    log ERROR, "This program does not work without root.") unless $*USER == 0;

    @RULES_DIRS.prepend($rules-dir) if $rules-dir.defined;

    for @RULES_DIRS -> $rule-dir where {
      { ($_ = "$*CWD/{$_.substr(2)}" if $_.starts-with("./")) } && $_.IO.r ||
      (log ERROR, "Rules directory is not readable or does not exist (may need to run as root?): $_") && exit 1; } {

      if $rule-dir.IO.mode.comb[3..4].any > 4 {
        log WARN, "Insecure permissions found for $rule-dir, this may be a security risk";
      }

      for dir $rule-dir, test =>
        { "$rule-dir/$_".IO.f && !$_.ends-with(".ex"|".example") }
        -> $rule-file {

        my Rule $rule .= new(file => $rule-file);
      }
    }
  }
}
