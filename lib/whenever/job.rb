require 'shellwords'

module Whenever
  class Job
    attr_reader :at, :roles

    def initialize(options = {})
      @options = options
      @at                               = options.delete(:at)
      @template                         = options.delete(:template)
      @job_template                     = options.delete(:job_template) || ":job"
      @roles                            = Array.wrap(options.delete(:roles))
      @options[:output]                 = options.has_key?(:output) ? Whenever::Output::Redirection.new(options[:output]).to_s : ''
      @options[:environment_variable] ||= "RAILS_ENV"
      @options[:environment]          ||= :production
      @options[:path]                   = Shellwords.shellescape(@options[:path] || Whenever.path)
    end

    def output
      opts = templatize_options(@options)
      job  = process_template(@template, opts).strip
      out  = process_template(@job_template, { :job => job }).strip
      if out =~ /\n/
        raise ArgumentError, "Task contains newline"
      end
      out.gsub(/%/, '\%')
    end

    def has_role?(role)
      roles.empty? || roles.include?(role)
    end

  protected

    def templatize_options opts
      opts.inject({}) do |new_opts, (key, temp)|
        new_opts[key] = temp.is_a?(String) ? process_template(temp, opts) : temp
        new_opts
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
      end
    end

    def escape_single_quotes(str)
      str.gsub(/'/) { "'\\''" }
    end

    def escape_double_quotes(str)
      str.gsub(/"/) { '\"' }
    end
  end
end
