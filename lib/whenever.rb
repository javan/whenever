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
%w{ 
base 
version 
job_list 
job_types/default 
job_types/rake_task 
job_types/runner 
outputs/cron
command_line 
}.each { |file| require	File.expand_path(File.dirname(__FILE__) + "/#{file}") }