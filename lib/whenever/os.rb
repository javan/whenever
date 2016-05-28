module Whenever
  module OS
    def self.solaris?
      (/solaris/ =~ RUBY_PLATFORM)
    end
  end
end
