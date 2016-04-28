require 'shellwords'
require 'whenever/random_offset'

module Whenever
  class Job
    attr_reader :at, :roles

    def initialize(options = {})
      @options = options
      @at                               = options.delete(:at)
      @template                         = options.delete(:template)
      @job_template                     = options.delete(:job_template) || ":job"
      @roles                            = Array(options.delete(:roles))
      @random_offset                    = options.delete(:random_offset) || 0
      @options[:output]                 = options.has_key?(:output) ? Whenever::Output::Redirection.new(options[:output]).to_s : ''
      @options[:environment_variable] ||= "RAILS_ENV"
      @options[:environment]          ||= :production
      @options[:path]                   = Shellwords.shellescape(@options[:path] || Whenever.path)
    end

    def output
      job = process_template(@template, @options)
      out = process_template(@job_template, @options.merge(:job => job))
      out = apply_random_offset(out)
      out.gsub(/%/, '\%')
    end

    def has_role?(role)
      roles.empty? || roles.include?(role)
    end

  protected

    def apply_random_offset(templated_job)
      if @random_offset > 0
        random_sleep_expr = Whenever::RandomOffset.sleep_expression(@random_offset)
        templated_sleep_job = process_template(@job_template, :job => random_sleep_expr)
        [templated_sleep_job, templated_job].join(' && ')
      else
        templated_job
      end
    end

    def process_template(template, options)
      template.gsub(/:\w+/) do |key|
        before_and_after = [$`[-1..-1], $'[0..0]]
        option = options[key.sub(':', '').to_sym] || key

        if before_and_after.all? { |c| c == "'" }
          escape_single_quotes(option)
        elsif before_and_after.all? { |c| c == '"' }
          escape_double_quotes(option)
        else
          option
        end
      end.gsub(/\s+/m, " ").strip
    end

    def escape_single_quotes(str)
      str.gsub(/'/) { "'\\''" }
    end

    def escape_double_quotes(str)
      str.gsub(/"/) { '\"' }
    end
  end
end
