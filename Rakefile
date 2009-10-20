require 'rubygems'
require 'rake'

require 'lib/whenever/version.rb'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "whenever"
    gemspec.version     = Whenever::VERSION
    gemspec.summary     = "Clean ruby syntax for defining and deploying messy cron jobs."
    gemspec.description = "Clean ruby syntax for defining and deploying messy cron jobs."
    gemspec.email       = "javan@javan.us"
    gemspec.homepage    = "http://github.com/javan/whenever"
    gemspec.authors     = ["Javan Makhmali"]
    gemspec.add_dependency("chronic", '>= 0.2.3')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/*.rb'
  test.verbose = true
end

task :test => :check_dependencies

task :default => :test