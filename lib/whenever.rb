require 'chronic'
require 'active_support/all'
require 'thread'

require 'whenever/job_list'
require 'whenever/job'
require 'whenever/cron'
require 'whenever/output_redirection'
require 'whenever/command_line'
require 'whenever/version'

module Whenever
  
  def self.cron(options)
    Whenever::JobList.new(options).generate_cron_output
  end
  
  def self.path
    Dir.pwd
  end

  def self.rails3?
    File.exists?(File.join(path, 'script', 'rails'))
  end

end
