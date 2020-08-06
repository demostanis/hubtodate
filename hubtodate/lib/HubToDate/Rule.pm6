use HubToDate::Parse;
use HubToDate::Log;
use HubToDate::Repository;
use HubToDate::Release;
use HubToDate::Verification;
use HubToDate::Options;

package HubToDate::Rule {
  role Rule is export {
    # A valid rule is composed of:
    #  - a repository field
    #  - a release field
    #  - a verification field
    #  - an optional options field

    has IO::Path:D $.file;
    has Repository:D $!repository;
    has Release:D $!release;
    has Verification:D $!verification;
    has Options:D $!options;

    submethod BUILD(IO::Path:D :$!file where *.f) {
      log VERBOSE, "Parsing rule {$!file.basename}...";
      my %contents = parse($!file);

      # In case those three fields are missing,
      # throw an error
      for <repository release verification> -> $field {
        %contents{$field} //
          log ERROR, "Missing [$field] in rule {$!file.basename}";
      }
      # Options are optional
      %contents{"options"} = {} unless %contents{"options"};

      # Repository, Release, Verification and Options classes
      # all inherit from the Setting class, which takes three
      # positional arguments:
      #  - settings => the field's key = value pairs from the rule file
      #  - available => the keys which the setting understands
      #  - rule => the rule itself

      # Available keys can end with a '?', meaning they are optional
      $!repository = Repository.new: settings => %contents{'repository'},
                                      available => <on? owner name>,
                                      rule => self;
      $!release = Release.new: settings => %contents{'release'},
                                available => <match unpack? install root?>,
                                rule => self;
      $!verification = Verification.new: settings => %contents{'verification'},
                                          available => <sha256sums? gpgkey?>,
                                          rule => self;
      $!options = Options.new: settings => %contents{'options'},
                                available => <silent? ignore-invalid-gpg-key?>,
                                rule => self;

      # First, verify if all the required key = value pairs are found...
      .verify for ($!repository, $!release, $!verification, $!options);
      # ... then, fetch => download => check => unpack => install
      # (more explained into their respective subroutines)
      $!release.install(:$!options, folder =>
        $!release.unpack(:$!options, archive =>
          $!verification.check(:$!options, stuff =>
            $!release.download(:$!options, stuff =>
              $!repository.fetch(:$!options)))));

      # This way is gross, it doesn't allow us to pass whenever
      # a rule is disabled (or anything else not requiring to exit)
      # We should instead try a way with promises: in case any of each
      # returned by those subroutines isn't kept, head on to next rule
    }
  }
}
