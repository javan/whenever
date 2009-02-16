module Whenever
  module Job
    class Runner < Whenever::Job::Default
      
      def initialize(options = {})
        super(options)
        
        @environment = options[:environment] || :production
        
        if [Whenever::Job::Runner.rails_root, options[:path]].all?(&:blank?)
          raise ArgumentError, "no cron_path available for runner to use"
        else
          @path = options[:path] || Whenever::Job::Runner.rails_root
        end
      end
      
      def self.rails_root
        if defined?(RAILS_ROOT)
          RAILS_ROOT 
        elsif defined?(::RAILS_ROOT)
          ::RAILS_ROOT
        end
      end

      def output
        %Q(#{File.join(@path, 'script', 'runner')} -e #{@environment} "#{task}")
      end
    end
  end
end
