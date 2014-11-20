module Whenever
  module Output
    class Command
      def to_s(command)
        " >( #{command} ) "
      end
    end

    class MailCommand < Command
      attr_reader :subject, :from, :to
      def initialize(options={})
        raise ArgumentError, "MailCommand must have a subject" unless options[:subject]
        raise ArgumentError, "MailCommand must have a from" unless options[:from]
        raise ArgumentError, "MailCommand must have a to" unless options[:to]

        @subject = "-s \"#{options[:subject]}\""
        @from = "-r \"#{options[:from]}\""
        @to = options[:to].is_a?(Array) ? options[:to].join(' ') : options[:to]
      end

      def to_s
        super("mail -E #{subject} #{from} #{to}")
      end
    end

    class LoggerCommand < Command
      attr_reader :tag
      def initialize(options)
        raise ArgumentError, "LoggerCommand must have a tag" unless options[:tag]
        @tag = options[:tag]
      end

      def to_s
        super("logger -t #{tag}")
      end
    end

    class TeeCommand < Command
      attr_reader :commands
      def initialize(*commands)
        @commands = commands
      end

      def to_s
        super("tee #{commands.join(' ')} > /dev/null")
      end
    end

    class Redirection
      def initialize(output)
        @output = output
      end

      def to_s
        return '' unless defined?(@output)
        case @output
          when Command, String  then redirect_from_string
          when Hash             then redirect_from_hash
          when NilClass         then ">> /dev/null 2>&1"
          when Proc             then @output.call
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
