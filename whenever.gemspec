# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "whenever/version"

Gem::Specification.new do |s|
  s.name        = "whenever"
  s.version     = Whenever::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Javan Makhmali"]
  s.email       = ["javan@javan.us"]
  s.license     = "MIT"
  s.homepage    = "https://github.com/javan/whenever"
  s.summary     = %q{Cron jobs in ruby.}
  s.description = %q{Clean ruby syntax for writing and deploying cron jobs.}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/{functional,unit}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 1.9.3"

  s.add_dependency "chronic", ">= 0.6.3"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "mocha", ">= 0.9.5"
  s.add_development_dependency "minitest"
  s.add_development_dependency "appraisal"
end
