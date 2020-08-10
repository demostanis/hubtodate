# We use Colorizable as it is easy to use
# and because \033[ makes things unreadable
use Colorizable;

package HubToDate::Log {
  # Different logging levels
  enum Level is export <VERBOSE WARN ERROR>;

  # We here log the message concatenated with the
  # chosen prefix, and we call &action if it is defined
  proto log(Level:D $level, Str:D $message) is export {
    (my $color, my $prefix, my &action, my &using is default(&say)) = {*};
    if $*OUT.t {
      using .colorize: :fg($color), :mo(bold)
        with $prefix ~ $message but Colorizable;
    } else {
      # Don't colorize nor prefix
      # message if standard output
      # is not a TTY
      using $message;
    }
    action if &action.defined;
  }

  multi log(VERBOSE;; Str:D --> List) { green, " ==> " }
  multi log(WARN;; Str:D --> List) { yellow, " [!] " }
  multi log(ERROR;; Str:D --> List) { red, " [!!!] ",
    sub { exit 1 }, &note } # We should always exit on error
                            # and print to standard error
}
