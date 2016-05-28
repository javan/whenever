module Whenever
    module OS
      def OS.solaris?
        (/solaris/ =~ RUBY_PLATFORM)
      end

      def OS.smartos?
        OS.solaris?
      end
    end
end
