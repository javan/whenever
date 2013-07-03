module Whenever
  module Output
    class Redirection
      def initialize(output)
        @output = output
      end
      
      def to_s
        return '' unless defined?(@output)
        case @output
          when String   then redirect_from_string
          when Hash     then redirect_from_hash
          when NilClass then ">> /dev/null 2>&1"
          when Proc     then @output.call
          else ''
        end 
      end
      
    protected
      
      def stdout
        return unless @output.has_key?(:standard)
        @output[:standard].nil? ? '/dev/null' : @output[:standard]
      end

      def stderr
        return unless @output.has_key?(:error)
        @output[:error].nil? ? '/dev/null' : @output[:error]
      end

      def redirect_from_hash
        case
          when stdout == '/dev/null' && stderr == '/dev/null'
            "> /dev/null 2>&1"
          when stdout && stderr == '/dev/null'
            ">> #{stdout} 2> /dev/null"
          when stdout && stderr
            ">> #{stdout} 2>> #{stderr}"
          when stderr == '/dev/null'
            "2> /dev/null"
          when stderr
            "2>> #{stderr}"
          when stdout == '/dev/null'
            "> /dev/null"
          when stdout
            ">> #{stdout}"
          else
            ''
        end
      end

      def redirect_from_string
        ">> #{@output} 2>&1"
      end
    end
  end
end
