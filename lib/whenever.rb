unless defined?(Whenever)
  $:.unshift(File.dirname(__FILE__))
   
  # Hoping to load Rails' Rakefile
  begin
    load 'Rakefile'
  rescue LoadError => e
    nil
  end
end

require 'chronic'

# If Rails' rakefile was loaded than so was activesupport, but
# if this is being used in a non-rails enviroment we need to require it.
# It was previously defined as a dependency of this gem, but that became
# problematic. See: http://github.com/javan/whenever/issues#issue/1
begin
  require 'activesupport'
rescue LoadError => e
  warn 'To user Whenever you need the activesupport gem:'
  warn '$ sudo gem install activesupport'
  exit(1)
end

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