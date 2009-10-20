require 'chronic'

# Hoping to load Rails' Rakefile
begin
  load 'Rakefile'
rescue LoadError
  nil
end

# If Rails' rakefile was loaded than so was activesupport, but
# if this is being used in a non-rails enviroment we need to require it.
# It was previously defined as a dependency of this gem, but that became
# problematic. See: http://github.com/javan/whenever/issues#issue/1
begin
  require 'activesupport'
rescue LoadError
  warn 'To user Whenever you need the activesupport gem:'
  warn '$ sudo gem install activesupport'
  exit(1)
end

# Whenever files
require 'whenever/base'
require 'whenever/job_list'
require 'whenever/job_types/default'
require 'whenever/job_types/rake_task'
require 'whenever/job_types/runner'
require 'whenever/outputs/cron'
require 'whenever/outputs/cron/output_redirection'
require 'whenever/command_line'
require 'whenever/version'