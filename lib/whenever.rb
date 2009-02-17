unless defined?(Whenever)
  $:.unshift(File.dirname(__FILE__))
   
  # Hoping to load Rails' Rakefile
  begin
    load 'Rakefile'
  rescue LoadError => e
    nil
  end
  
  # Load Whenever's rake tasks
  begin
    Dir[File.join(File.dirname(__FILE__), 'tasks', '*.rake')].each { |rake| load rake }
  rescue LoadError => e
    nil
  end
  
end


require 'activesupport'
require 'chronic'

require 'base'
require 'job_list'
require 'job_types/default'
require 'job_types/rake_task'
require 'job_types/runner'
require 'outputs/cron'
