unless defined?(Whenever)
  $:.unshift(File.dirname(__FILE__))
   
  # Hoping to load Rails' Rakefile
  begin
    load 'Rakefile'
  rescue LoadError => e
    nil
  end
end

# Dependencies
require 'activesupport'
require 'chronic'

# Whenever files
require 'base'
require 'version'
require 'job_list'
require 'job_types/default'
require 'job_types/rake_task'
require 'job_types/runner'
require 'outputs/cron'
