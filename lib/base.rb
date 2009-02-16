require 'job_list'
require 'job_types/default'
require 'job_types/runner'
require 'outputs/cron'

module Whenever
  VERSION = '0.1.0'
  
  def self.cron(options)
    Whenever::JobList.new(options).generate_cron_output
  end
end