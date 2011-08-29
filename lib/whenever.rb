require 'chronic'
begin
  require 'active_support/version'
rescue LoadError
  # no activesupport - use our fallback.
  require 'whenever/time_extensions'
else
  # some version of activesupport is available.
  # we only need time extensions.
  require 'active_support/core_ext/integer/time'
  require 'active_support/core_ext/numeric/time'
  
  # however, activesupport pieces do not require their dependencies,
  # therefore we must do so for them.
  
  if ActiveSupport::VERSION::MAJOR == 2 && ActiveSupport::VERSION::MINOR == 3
    if ActiveSupport::VERSION::TINY < 11
      # active_support/duration requires active_support/basic_object,
      # which in turn requires blankslate (part of builder) on ruby 1.8.
      # builder may or may not exist systemwide, in the latter case
      # activesupport requires a bundled vendored copy of it.
      # just give up and require everything.
      require 'active_support'
    else
      # activesupport is more disciplined, and we only need to require
      # all of integer and numeric core extensions to get the extension methods
      # actually included in the core classes.
      require 'active_support/core_ext/integer'
      require 'active_support/core_ext/numeric'
    end
  end
  
  # time extensions use ActiveSupport::Duration but do not require it.
  # this is the only piece needed for activesupport 3.0.
  require 'active_support/duration'
  
  # require of thread is needed to correct activesupport < 2.3.11
  # breaking with rubygems >= 1.6.0 - see issue #132
  require 'thread'
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
