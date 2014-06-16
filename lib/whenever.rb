require 'thread'
require 'active_support/all'

module Whenever
  autoload :JobList,           'whenever/job_list'
  autoload :Job,               'whenever/job'
  autoload :CommandLine,       'whenever/command_line'

  module Output
    autoload :Cron,        'whenever/cron'
    autoload :Redirection, 'whenever/output_redirection'
  end

  def self.cron(options)
    Whenever::JobList.new(options).generate_cron_output
  end

  def self.path
    Dir.pwd
  end

  def self.bin_rails?
    File.exists?(File.join(path, 'bin', 'rails'))
  end

  def self.script_rails?
    File.exists?(File.join(path, 'script', 'rails'))
  end

  def self.bundler?
    File.exists?(File.join(path, 'Gemfile'))
  end

  # Return the number of seconds in `num` minutes
  def self.minutes(num)
    num.to_i * 60
  end

  # Return the number of seconds in `num` hours
  def self.hours(num)
    num.to_i * 3_600
  end

  # Return the number of seconds in `num` days
  def self.days(num)
    num.to_i * 86_400
  end

  # Return the number of seconds in `num` weeks
  def self.weeks(num)
    num.to_i * 604_800
  end

  # Return the number of seconds in `num` months
  def self.months(num)
    num.to_i * 2_592_000
  end
end
