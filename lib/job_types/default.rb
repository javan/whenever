module Whenever
  module Job
    class Default
      attr_accessor :task, :at, :cron_log
    
      def initialize(options = {})
        @task     = options[:task]
        @at       = options[:at]
        @cron_log = options[:cron_log]
      end
    
      def output
        task
      end
    end
  end
end