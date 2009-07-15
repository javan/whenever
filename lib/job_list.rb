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
      set_path_environment_variable
      
      [environment_variables, cron_jobs].compact.join
    end
    
  private
    
    #
    # Takes a string like: "variable1=something&variable2=somethingelse"
    # and breaks it into variable/value pairs. Used for setting variables at runtime from the command line.
    # Only works for setting values as strings.
    #
    def pre_set(variable_string = nil)
      return if variable_string.blank?
      
      pairs = variable_string.split('&')
      pairs.each do |pair|
        next unless pair.index('=')
        variable, value = *pair.split('=')
        set(variable.strip, value.strip) unless variable.blank? || value.blank?
      end
    end
    
    def set_path_environment_variable
      return if path_should_not_be_set_automatically?
      @env[:PATH] = read_path unless read_path.blank?
    end
    
    def read_path
      ENV['PATH'] if ENV
    end
    
    def path_should_not_be_set_automatically?
      @set_path_automatically === false || @env[:PATH] || @env["PATH"]
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
    
    #
    # Takes the standard cron output that Whenever generates and finds
    # similar entries that can be combined. For example: If a job should run
    # at 3:02am and 4:02am, instead of creating two jobs this method combines
    # them into one that runs on the 2nd minute at the 3rd and 4th hour.
    #
    def combine(entries)
      entries.map! { |entry| entry.split(/ +/,6 )}
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

    def cron_jobs
      return if @jobs.empty?
      
      output = []
      @jobs.each do |time, jobs|
        jobs.each do |job|
          Whenever::Output::Cron.output(time, job) do |cron|
            cron << " >> #{job.cron_log} 2>&1" if job.cron_log 
            cron << "\n\n"
            output << cron
          end
        end
      end
      
      combine(output).join
    end
    
  end
end
