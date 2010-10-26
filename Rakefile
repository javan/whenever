require 'rubygems'
require 'rake'

require File.expand_path(File.dirname(__FILE__) + "/lib/whenever/version")

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "whenever"
    gemspec.version     = Whenever::VERSION
    gemspec.summary     = "Write your cron jobs in ruby."
    gemspec.description = "Clean ruby syntax for writing and deploying cron jobs."
    gemspec.email       = "javan@javan.us"
    gemspec.homepage    = "http://github.com/javan/whenever"
    gemspec.authors     = ["Javan Makhmali"]
    gemspec.add_dependency 'aaronh-chronic', '>= 0.3.9'
    gemspec.add_dependency 'activesupport', '>= 2.3.4'
    gemspec.add_development_dependency 'shoulda', '>= 2.1.1'
    gemspec.add_development_dependency 'mocha', '>= 0.9.5'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
    test.libs      << 'lib' << 'test'
    test.pattern   = 'test/{functional,unit}/**/*_test.rb'
    test.verbose   = true
  end

task :test => :check_dependencies

task :default => :test