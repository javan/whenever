module Whenever
  class JobList
  
    def initialize(options)
      @jobs = Hash.new
      @env  = Hash.new
      
      case options
        when String
          config = options
        when Hash
          config = if options[:string]
            options[:string]
          elsif options[:file]
            File.read(options[:file])
          end
          pre_set(options[:set])
      end

      eval(config)
    end
    
    def set(variable, value)
      return if instance_variable_defined?("@#{variable}".to_sym)
      
      instance_variable_set("@#{variable}".to_sym, value)
      self.class.send(:attr_reader, variable.to_sym)
    end
    
    def env(variable, value)
      @env[variable.to_s] = value
    end
  
    def every(frequency, options = {})
      @current_time_scope = frequency
      @options = options
      yield
    end
    
    def command(task, options = {})
      options[:cron_log] ||= @cron_log unless options[:cron_log] === false
      options[:class]    ||= Whenever::Job::Default
      @jobs[@current_time_scope] ||= []
      @jobs[@current_time_scope] << options[:class].new(@options.merge(:task => task).merge(options))
    end
    
    def runner(task, options = {})
      options.reverse_merge!(:environment => @environment, :path => @path)
      options[:class] = Whenever::Job::Runner
      command(task, options)
    end
    
    def rake(task, options = {})
      options.reverse_merge!(:environment => @environment, :path => @path)
      options[:class] = Whenever::Job::RakeTask
      command(task, options)
    end
  
    def generate_cron_output
      [environment_variables, cron_jobs].compact.join
    end
    
  private
    
    # Takes a string like: "variable1=something&variable2=somethingelse"
    # and breaks it into variable/value pairs. Used for setting variables at runtime from the command line.
    # Only works for setting values as strings.
    def pre_set(variable_string = nil)
      return if variable_string.blank?
      
      pairs = variable_string.split('&')
      pairs.each do |pair|
        next unless pair.index('=')
        variable, value = *pair.split('=')
        set(variable.strip, value.strip) unless variable.blank? || value.blank?
      end
    end
  
    def environment_variables
      return if @env.empty?
      
      output = []
      @env.each do |key, val|
        output << "#{key}=#{val}\n"
      end
      output << "\n"
      
      output.join
    end
    
    def cron_jobs
      return if @jobs.empty?
      
      output = []
      @jobs.each do |time, jobs|
        jobs.each do |job|
          cron = Whenever::Output::Cron.output(time, job)
          cron << " >> #{job.cron_log} 2>&1" if job.cron_log 
          cron << "\n\n"
          output << cron
        end
      end
      
      output.join
    end
    
  end
end