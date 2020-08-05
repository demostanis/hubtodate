use HubToDate::Parse;
use HubToDate::Log;
use HubToDate::Repository;
use HubToDate::Release;
use HubToDate::Verification;
use HubToDate::Options;

package HubToDate::Rule {
  role Rule is export {
    has IO::Path $.file;
    has Repository $!repository;
    has Release $!release;
    has Verification $!verification;
    has Options $!options;

    submethod BUILD(IO::Path :$!file where *.f) {
      log VERBOSE, "Parsing rule {$!file.basename}...";
      my %contents = parse($!file);

      for <repository release verification options> {
        %contents{$_} //
          log ERROR, "Missing [$_] in rule {$!file.basename}";
      }

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

      .verify for ($!repository, $!release, $!verification, $!options);
      $!release.install(:$!options, folder =>
        $!release.unpack(:$!options, archive =>
          $!verification.check(:$!options, stuff =>
            $!release.download(:$!options, stuff =>
              $!repository.fetch(:$!options)))));
    }
  }
}
