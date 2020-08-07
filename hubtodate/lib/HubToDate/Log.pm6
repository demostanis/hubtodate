# We use Colorizable as it is easy to use
# and because \033[ makes things unreadable
use Colorizable;

package HubToDate::Log {
  # Different logging levels
  enum Level is export <VERBOSE WARN ERROR>;

  # We here log the message concatenated with the
  # chosen prefix, and we call &action if it is defined
  proto log(Level:D $level, Str:D $message) is export {
    my ($color, $prefix, &action) = {*};
    say .colorize: :fg($color), :mo(bold)
      with $prefix ~ $message but Colorizable;
    action if &action.defined;
  }

  multi log(VERBOSE;; Str:D --> List) { green, " ==> " }
  multi log(WARN;; Str:D --> List) { yellow, " [!] " }
  multi log(ERROR;; Str:D --> List) { red, " [!!!] ", &die } # We should always die on error
}
