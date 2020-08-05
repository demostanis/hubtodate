use HubToDate::Log;

package HubToDate::Setting {
  role Setting is export {
    has $.rule;
    has @.available;
    has %.settings;
    has $.name;

    submethod BUILD(::("Rule") :$!rule, :%!settings, :@!available) {
    }

    method verify {
      my $field = $::(self.^name)::name;
      for @!available -> $setting {
        (%!settings{$setting} or $setting.ends-with('?'))
        || log ERROR, "Missing $setting inside of [$field] in rule {$!rule.file.basename}";
      }
    }
  }
}
