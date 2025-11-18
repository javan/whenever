# frozen_string_literal: true

require_relative "lib/whenever/version"

Gem::Specification.new do |spec|
  spec.name        = "whenever"
  spec.version     = Whenever::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ["Javan Makhmali"]
  spec.email       = ["javan@javan.us"]

  spec.summary     = %q{Cron jobs in ruby.}
  spec.description = %q{Clean ruby syntax for writing and deploying cron jobs.}
  spec.homepage    = "https://github.com/javan/whenever"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 1.9.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/javan/whenever"
  spec.metadata["changelog_uri"] = "https://github.com/javan/whenever/blob/main/CHANGELOG.md"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- test/{functional,unit}/*`.split("\n")
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "chronic", ">= 0.6.3"
end
