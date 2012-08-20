require 'shellwords'

module Whenever
  class Job
    attr_reader :at, :server_roles

    def initialize(options = {})
      @options = options
      @at                      = options.delete(:at)
      @template                = options.delete(:template)
      @job_template            = options.delete(:job_template) || ":job"
      @server_roles            = options.delete(:on_server_roles) || []
      @options[:output]        = Whenever::Output::Redirection.new(options[:output]).to_s if options.has_key?(:output)
      @options[:environment] ||= :production
      @options[:path]          = Shellwords.shellescape(@options[:path] || Whenever.path)

      @server_roles = [@server_roles] unless @server_roles.is_a?(Array)
    end

    def output
      job = process_template(@template, @options).strip
      out = process_template(@job_template, { :job => job }).strip
      if out =~ /\n/
        raise ArgumentError, "Task contains newline"
      end
      out.gsub(/%/, '\%')
    end

    def has_server_role?(role)
      server_roles.empty? || server_roles.include?(role)
    end

  protected

    def process_template(template, options)
      template.gsub(/:\w+/) do |key|
        before_and_after = [$`[-1..-1], $'[0..0]]
        option = options[key.sub(':', '').to_sym]

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
