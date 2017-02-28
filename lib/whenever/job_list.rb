module Whenever
  class JobList
    attr_reader :roles

    def initialize(options)
      @jobs, @env, @set_variables, @pre_set_variables = {}, {}, {}, {}

      if options.is_a? String
        options = { :string => options }
      end

      pre_set(options[:set])

      @roles = options[:roles] || []

      setup_file = File.expand_path('../setup.rb', __FILE__)
      setup = File.read(setup_file)
      schedule = if options[:string]
        options[:string]
      elsif options[:file]
        File.read(options[:file])
      end

      instance_eval(setup, setup_file)
      instance_eval(schedule, options[:file] || '<eval>')
    end

    def set(variable, value)
      variable = variable.to_sym
      return if @pre_set_variables[variable]

      instance_variable_set("@#{variable}".to_sym, value)
      @set_variables[variable] = value
    end

    def method_missing(name, *args, &block)
      @set_variables.has_key?(name) ? @set_variables[name] : super
    end

    def self.respond_to?(name, include_private = false)
      @set_variables.has_key?(name) || super
    end

    def env(variable, value)
      @env[variable.to_s] = value
    end

    def every(frequency, options = {})
      @current_time_scope = frequency
      @options = options
      yield
    end

    def job_type(name, template)
      singleton_class.class_eval do
        define_method(name) do |task, *args|
          options = { :task => task, :template => template }
          options.merge!(args[0]) if args[0].is_a? Hash

          options[:mailto] ||= @options.fetch(:mailto, :default_mailto)

          # :cron_log was an old option for output redirection, it remains for backwards compatibility
          options[:output] = (options[:cron_log] || @cron_log) if defined?(@cron_log) || options.has_key?(:cron_log)
          # :output is the newer, more flexible option.
          options[:output] = @output if defined?(@output) && !options.has_key?(:output)

          @jobs[options.fetch(:mailto)] ||= {}
          @jobs[options.fetch(:mailto)][@current_time_scope] ||= []
          @jobs[options.fetch(:mailto)][@current_time_scope] << Whenever::Job.new(@options.merge(@set_variables).merge(options))
        end
      end
    end

    def generate_cron_output
      [environment_variables, cron_jobs].compact.join
    end

  private

    #
    # Takes a string like: "variable1=something&variable2=somethingelse"
    # and breaks it into variable/value pairs. Used for setting variables at runtime from the command line.
    # Only works for setting values as strings.
    #
    def pre_set(variable_string = nil)
      return if variable_string.nil? || variable_string == ""

      pairs = variable_string.split('&')
      pairs.each do |pair|
        next unless pair.index('=')
        variable, value = *pair.split('=')
        unless variable.nil? || variable == "" || value.nil? || value == ""
          variable = variable.strip.to_sym
          set(variable, value.strip)
          @pre_set_variables[variable] = value
        end
      end
    end

    def environment_variables
      return if @env.empty?

      output = []
      @env.each do |key, val|
        output << "#{key}=#{val.nil? || val == "" ? '""' : val}\n"
      end
      output << "\n"

      output.join
    end

    #
    # Takes the standard cron output that Whenever generates and finds
    # similar entries that can be combined. For example: If a job should run
    # at 3:02am and 4:02am, instead of creating two jobs this method combines
    # them into one that runs on the 2nd minute at the 3rd and 4th hour.
    #
    def combine(entries)
      entries.map! { |entry| entry.split(/ +/, 6) }
      0.upto(4) do |f|
        (entries.length-1).downto(1) do |i|
          next if entries[i][f] == '*'
          comparison = entries[i][0...f] + entries[i][f+1..-1]
          (i-1).downto(0) do |j|
            next if entries[j][f] == '*'
            if comparison == entries[j][0...f] + entries[j][f+1..-1]
              entries[j][f] += ',' + entries[i][f]
              entries.delete_at(i)
              break
            end
          end
        end
      end

      entries.map { |entry| entry.join(' ') }
    end

    def cron_jobs_of_time(time, jobs)
      shortcut_jobs, regular_jobs = [], []

      jobs.each do |job|
        next unless roles.empty? || roles.any? do |r|
          job.has_role?(r)
        end
        Whenever::Output::Cron.output(time, job, :chronic_options => @chronic_options) do |cron|
          cron << "\n\n"

          if cron[0,1] == "@"
            shortcut_jobs << cron
          else
            regular_jobs << cron
          end
        end
      end

      shortcut_jobs.join + combine(regular_jobs).join
    end

    def cron_jobs
      return if @jobs.empty?

      output = []

      # jobs with default mailto's must be output before the ones with non-default mailto's.
      @jobs.delete(:default_mailto) { Hash.new }.each do |time, jobs|
        output << cron_jobs_of_time(time, jobs)
      end

      @jobs.each do |mailto, time_and_jobs|
        output_jobs = []

        time_and_jobs.each do |time, jobs|
          output_jobs << cron_jobs_of_time(time, jobs)
        end

        output_jobs.reject! { |output_job| output_job.empty? }

        output << "MAILTO=#{mailto}\n\n" unless output_jobs.empty?
        output << output_jobs
      end

      output.join
    end
  end
end
