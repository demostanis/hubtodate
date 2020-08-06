# We aren't importing HubToDate::Rule here,
# else it would throw errors. That's why we
# use the ::('Rule')
use HubToDate::Log;

package HubToDate::Setting {
  role Setting is export {
    has ::("Rule") $.rule;
    has List:D @.available;
    has Hash:D %.settings;
    has Str:D $.name;

    submethod BUILD(
      :$!rule,
      :%!settings,
      :@!available
    ) {}

    # We verify for each key = value pairs,
    # in case one is required, for its
    # existance. If it doesn't exist,
    # throw an error
    method verify {
      # self.^name here is not Setting class,
      # but the inheriting class
      my $field = $::(self.^name)::name;
      for @!available -> $setting {
        (%!settings{$setting} or $setting.ends-with('?'))
        || log ERROR, "Missing $setting inside of [$field] in rule {$!rule.file.basename}";
      }
    }
  }
}
