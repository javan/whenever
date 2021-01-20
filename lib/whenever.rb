require 'whenever/numeric'
require 'whenever/numeric_seconds'
require 'whenever/job_list'
require 'whenever/job'
require 'whenever/command_line'
require 'whenever/cron'
require 'whenever/output_redirection'
require 'whenever/os'

module Whenever
  def self.job_list(options)
    Whenever::JobList.new(options)
  end

  def self.cron(options)
    job_list(options).generate_cron_output
  end

  def self.seconds(number, units)
    Whenever::NumericSeconds.seconds(number, units)
  end

  def self.path
    Dir.pwd
  end

  def self.bin_rails?
    File.exist?(File.join(path, 'bin', 'rails'))
  end

  def self.script_rails?
    File.exist?(File.join(path, 'script', 'rails'))
  end

  def self.bundler?
    File.exist?(File.join(path, 'Gemfile'))
  end
end
