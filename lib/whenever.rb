require 'chronic'

# It was previously defined as a dependency of this gem, but that became
# problematic. See: http://github.com/javan/whenever/issues#issue/1
begin
  require 'active_support/all'
rescue LoadError
  warn 'To use Whenever you need the active_support gem:'
  warn '$ gem install activesupport'
  exit(1)
end

# Whenever files
require 'whenever/base'
require 'whenever/job_list'
require 'whenever/job'
require 'whenever/outputs/cron'
require 'whenever/outputs/cron/output_redirection'
require 'whenever/command_line'
require 'whenever/version'