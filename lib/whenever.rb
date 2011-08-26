require 'chronic'
begin
  # whenever only needs time extensions, however it is not possible
  # to obtain them by requiring files only.
  # because of this we requre all integer and numeric extensions.
  require 'active_support/core_ext/integer'
  require 'active_support/core_ext/numeric'
  # require of thread is needed to correct activesupport < 2.3.11
  # breaking with rubygems >= 1.6.0 - see issue #132
  require 'thread'
rescue LoadError
  require 'whenever/time_extensions'
end

module Whenever
  autoload :JobList,     'whenever/job_list'
  autoload :Job,         'whenever/job'
  autoload :CommandLine, 'whenever/command_line'
  
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

  def self.rails3?
    File.exists?(File.join(path, 'script', 'rails'))
  end

  def self.bundler?
    File.exists?(File.join(path, 'Gemfile'))
  end
  
  def self.string_blank?(string)
    if string.respond_to?(:blank?)
      string.blank?
    else
      string.nil? || string.strip.empty?
    end
  end
end
