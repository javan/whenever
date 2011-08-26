begin
  require 'bundler'
rescue LoadError => e
  warn("warning: Could not load bundler: #{e}")
  warn("         Some rake tasks will not be defined")
else
  Bundler::GemHelper.install_tasks
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs      << 'lib' << 'test'
  test.pattern   = 'test/{functional,unit}/**/*_test.rb'
  test.verbose   = true
end

task :default => :test