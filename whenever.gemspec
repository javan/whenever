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
  s.files         = Dir.glob("**/*")
  s.test_files    = Dir.glob("test/{functional,test}/*")
  s.executables   = Dir.glob("bin/*").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 1.9.3"

  s.add_dependency "chronic", ">= 0.6.3"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "mocha", ">= 0.9.5", "< 2.0.0"
  s.add_development_dependency "minitest", "<= 5.2.0"
  s.add_development_dependency "appraisal"
end
