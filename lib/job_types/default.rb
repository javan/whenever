module Whenever
  module Job
    class Default
      
      attr_accessor :task, :at, :redirect
    
      def initialize(options = {})
        @task        = options[:task]
        @at          = options[:at]
        @redirect    = options[:output]
        @environment = options[:environment] || :production
        @path        = options[:path] || Whenever.path
      end
    
      def output
        task
      end
      
      def redirect_output
        case @redirect
        when String
          redirect_from_string
        when Hash
          redirect_from_hash
        when NilClass
          " >> /dev/null 2>&1"
        else
          ''
        end 
      end
      
    protected
      
      def stdout
        return unless @redirect.has_key?(:standard)
        @redirect[:standard].nil? ? '/dev/null' : @redirect[:standard]
      end
      
      def stderr
        return unless @redirect.has_key?(:error)
        @redirect[:error].nil? ? '/dev/null' : @redirect[:error]
      end
      
      def redirect_from_hash
        case
        when stdout == '/dev/null' && stderr == '/dev/null'
          " >> /dev/null 2>&1"
        when stdout && stderr
          " >> #{stdout} 2> #{stderr}"
        when stderr
          " 2> #{stderr}"
        when stdout
          " >> #{stdout}"
        else
          ''
        end
      end
      
      def redirect_from_string
        " >> #{@redirect} 2>&1"
      end
      
      def path_required
        raise ArgumentError, "No path available; set :path, '/your/path' in your schedule file" if @path.blank?
      end
      
    end
  end
end