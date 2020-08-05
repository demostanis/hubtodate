use Colorizable;

package HubToDate::Log {
  enum Level is export <VERBOSE WARN ERROR>;

  proto log(Level $level, Str $message) is export {
    my ($color, $prefix) = {*};
    say .colorize: :fg($color), :mo(bold)
      with $prefix ~ $message but Colorizable;
  }

  multi log(VERBOSE;; Str) { (green, " ==> "); }
  multi log(WARN;; Str) { (yellow, " [!] "); }
  multi log(ERROR;; Str) { (red, " [!!!] "); }
}
