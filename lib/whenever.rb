require 'thread'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/kernel/singleton_class'
require 'active_support/core_ext/array/wrap'

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
end
